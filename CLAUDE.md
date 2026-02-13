# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**claude-code-actions** — CI/CD automation framework for semantic-search-mcp project using GitHub Actions and Claude Code.

This repository contains **GitHub Actions workflows** and **system prompts** that enable fully automated software development lifecycle: from issue creation to production deployment. Claude Code agents with different roles (architect, debugger, implementer, reviewer) work together through GitHub Actions to implement features, fix bugs, review code, and release to production.

**Key Difference**: This is NOT the main codebase — this is the **automation layer** that orchestrates development of semantic-search-mcp project located at `/Users/artemgusarov/Downloads/PROJECTS/semantic-search-mcp`.

## Architecture

### Unified AI Pipeline

**Entry Point**: `.github/workflows/unified-ai-pipeline.yml`

Single workflow that routes all AI-triggered events to appropriate handlers:
- **@claude respond** → Quick responses (haiku/glm-4.5-air)
- **@claude review** → Code review (haiku/glm-4.5-air)
- **@claude implement** → Feature implementation (role-based model selection)
- **@claude release** → Production release pipeline
- **Linear webhooks** → Auto-implement on "In Progress" status

### Role-Based System

Each AI agent has a specific role with dedicated system prompt:

| Role | Model | Use Case | Prompt File |
|------|-------|----------|-------------|
| **architect** | opus (glm-4.7) | Research, exploration | `system-prompts/architect.md` |
| **architect** | sonnet (glm-4.7) | Architecture design | `system-prompts/architect.md` |
| **debugger** | haiku (glm-4.5-air) | Bug fixes | `system-prompts/debugger.md` |
| **implementer** | haiku (glm-4.5-air) | Features, refactoring | `system-prompts/implementer.md` |
| **reviewer** | sonnet (glm-4.7) | Code review | `system-prompts/reviewer.md` |
| **responder** | haiku (glm-4.5-air) | @claude mentions | `system-prompts/responder.md` |

Role selection is automatic based on issue labels:
- `research`, `explore` → architect (opus)
- `architecture` → architect (sonnet)
- `bug`, `fix` → debugger (haiku)
- `feature`, `enhancement` → implementer (haiku)

### Concurrency & Idempotency

**Concurrency Strategy**: Per-task serialization (no cancellation)
```yaml
concurrency:
  group: task-${{ linear_id || issue_number || run_id }}
  cancel-in-progress: false  # Queue runs, don't cancel!
```

**Why**: Prevents race conditions when multiple triggers arrive simultaneously (e.g., Linear webhook + @claude comment).

**Idempotency Checks** (before implementation):
1. Check for existing PR with Linear ID in title/body
2. Check for existing branch matching Linear ID
3. Check for concurrent runs of same task
4. Skip duplicate work, post notification

### MCP Servers Integration

**Configuration**: `.github/mcp-servers.json`

Available MCP servers:
- **linear-server** — Linear API integration (@anthropic-ai/linear-mcp)
- **github-server** — GitHub API operations (@modelcontextprotocol/server-github)
- **zai-mcp-server** — Screenshot analysis, UI to code (@z_ai/mcp-server)
- **web-search-prime** — Web search (z.ai HTTP API)
- **web-reader** — Webpage reading (z.ai HTTP API)
- **zread** — GitHub repository search (z.ai HTTP API)

**Usage Pattern**: MCP config is generated dynamically in workflows by substituting environment variables.

### Model Mapping

**Configuration**: `.github/claude-settings.json`

```json
{
  "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-4.7",
  "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-4.7",
  "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.5-air"
}
```

**Performance**: haiku (glm-4.5-air) is 2-3x faster than sonnet for simple tasks.

## Workflows

### Core Pipelines

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `unified-ai-pipeline.yml` | @claude, labels, Linear webhooks | Main AI orchestrator |
| `ci-pipeline.yml` | Push, PR | Run tests and linting |
| `cd-pipeline.yml` | Tag creation | Deploy to production |
| `integration-tests.yml` | Label `run-integration-tests` | Heavy tests with Qdrant |

### Linear Integration

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `linear-sync.yml` | Linear webhooks (status changes) | Sync status changes to GitHub |
| `pr-linear-sync.yml` | PR events | Sync PR status back to Linear |
| `sync-statuses.yml` | Scheduled (hourly) | Keep Linear ↔ GitHub in sync |

### Development Tools

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `claude-code-review.yml` | Label `needs-ai-review` | AI-powered code review |
| `dependency-tracker.yml` | Scheduled (weekly) | Check outdated dependencies |
| `release-notes.yml` | Tag creation | Auto-generate release notes |
| `sprint-planning.yml` | Manual/scheduled | Create sprint planning issues |
| `cleanup.yml` | Manual trigger | Clean up old merged branches |

### Implementation Workflow

**Typical flow when implementing a Linear issue**:

1. **Trigger**: Linear status → "In Progress" OR @claude implement OR label `claude-implement`
2. **Router Job**:
   - Filter bots (prevent duplicate runs)
   - Detect action type (implement/review/respond/release)
   - Select role & model based on labels
   - **Idempotency check**: Skip if PR/branch already exists
3. **Implement Job**:
   - Load system prompts (base + role + Linear guide + GitHub MCP guide)
   - Create MCP config with secrets
   - Notify start (GitHub comment + Linear comment)
   - Run Claude Code with:
     - Model: role-based selection
     - System prompt: multi-layered (base + role + integrations)
     - Prompt: issue details, dependencies, instructions
   - **Verification**:
     - Branch created and pushed
     - Tests pass (`pytest -v`)
   - Notify completion (Linear comment)

## Common Commands

### Testing Workflows Locally

```bash
# Validate workflow syntax
gh workflow view unified-ai-pipeline.yml

# List all workflows
gh workflow list

# Manually trigger workflow (for workflows with workflow_dispatch)
gh workflow run cleanup.yml
```

### Testing MCP Servers

```bash
# Test Linear MCP server
npx -y @anthropic-ai/linear-mcp

# Test GitHub MCP server
npx -y @modelcontextprotocol/server-github
```

### Development

```bash
# Validate workflow YAML files
yamllint .github/workflows/*.yml

# Check for secrets in code (NEVER commit secrets!)
git grep -iE "(api_key|secret|token|password)" -- '*.yml' '*.json'

# View workflow runs
gh run list --workflow=unified-ai-pipeline.yml

# Check specific run
gh run view <run-id>

# Cancel a run
gh run cancel <run-id>

# Re-run failed jobs
gh run rerun <run-id>
```

### Configuration Management

```bash
# Update MCP servers config
vim .github/mcp-servers.json

# Update Claude settings (model mapping, permissions)
vim .github/claude-settings.json

# Update workflow reference values
vim .github/workflow-config.yml

# Update system prompts
vim .github/system-prompts/<role>.md
```

## Critical Rules

### File Organization

- **Workflows** → `.github/workflows/`
- **System Prompts** → `.github/system-prompts/`
- **Configuration** → `.github/*.json`, `.github/*.yml`
- **Documentation** → `.github/*.md`

### Forbidden Actions

❌ **NEVER**:
- Mention "Claude", "Anthropic", or AI assistants in commit messages
- Commit secrets, API keys, or credentials
- Push directly to `main` branch
- Skip idempotency checks in workflows
- Hard-code secrets in workflow files (use `${{ secrets.* }}`)
- Create workflows without concurrency control
- Deploy without running tests

### Required Actions

✅ **ALWAYS**:
- Use `secrets.*` for sensitive data (LINEAR_API_KEY, ANTHROPIC_API_KEY, GITHUB_TOKEN)
- Add concurrency groups to prevent race conditions
- Include idempotency checks for implement actions
- Test workflows with `act` or GitHub Actions UI before merging
- Update `.github/workflow-config.yml` when changing reference values
- Follow naming conventions:
  - Branch: `feature/<linear-id>-description`
  - Commit: `<type>: <description> [LINEAR-ID]`
  - PR: `<type>: <description> [LINEAR-ID]`

## Workflow Configuration Reference

**Source**: `.github/workflow-config.yml`

### Timeouts (minutes)
- @claude responses: 30
- Label implementation: 45
- Assignment: 45
- Linear implementation: 60
- Code review: 20
- Integration tests: 15

### Artifact Retention (days)
- Test results: 3
- Release artifacts: 3

### Quota Limits
- Free tier: 2000 minutes/month
- Recommended daily limit: 66 minutes

### Trigger Labels
- `claude-implement` — Trigger auto-implementation
- `needs-ai-review` — Trigger code review
- `run-integration-tests` — Run heavy tests with Qdrant

## System Prompt Architecture

**Layered approach** (loaded in this order):

1. **Base Prompt** (`system-prompts/_base.md`)
   - Project identity
   - Search tool priority (semantic_search first!)
   - MCP tools priority (z.ai tools instead of built-in)
   - Forbidden actions (no THOUGHTS.md, no AI mentions in commits)
   - Required actions (skills, tests, verification)
   - Completion workflow (verification → feedback → report)
   - Linear integration (branch naming, commit format)
   - Code quality standards
   - MCP testing (no vibe-testing!)

2. **Role Prompt** (`system-prompts/<role>.md`)
   - Role-specific identity and mindset
   - Required skills to invoke
   - Workflow steps for this role
   - Anti-patterns to avoid

3. **Integration Guides** (optional)
   - `system-prompts/linear-integration.md` — Linear workflows
   - `system-prompts/github-mcp-usage.md` — GitHub MCP best practices

4. **Progress Instructions** (for implement jobs)
   - Progress reporting format
   - When to update tracking comment
   - Metadata (role, model, Linear ID, issue number)

## Development Workflow

### Adding New Workflow

1. Create workflow file in `.github/workflows/`
2. Add concurrency group to prevent race conditions
3. Document timeout in `.github/workflow-config.yml`
4. Add trigger labels if needed
5. Test with `gh workflow run` or `act`
6. Update this CLAUDE.md if workflow introduces new patterns

### Modifying System Prompts

1. Edit prompt file in `.github/system-prompts/`
2. Test with relevant workflow (e.g., `unified-ai-pipeline.yml`)
3. Verify AI agent follows new instructions
4. Update `.github/workflow-config.yml` if role mapping changes

### Updating MCP Servers

1. Edit `.github/mcp-servers.json`
2. Update cache key in workflows if needed:
   ```yaml
   key: ${{ runner.os }}-npx-mcp-${{ hashFiles('.github/mcp-servers.json') }}
   ```
3. Test MCP server locally with `npx`
4. Verify integration in workflow runs

## Secrets Management

**Required secrets** (GitHub repository settings):

| Secret | Purpose | Used In |
|--------|---------|---------|
| `ANTHROPIC_API_KEY` | Claude API access | All AI workflows |
| `LINEAR_API_KEY` | Linear API integration | Linear sync workflows |
| `GITHUB_TOKEN` | GitHub API operations | Auto-provided by Actions |
| `GEMINI_API_KEY` | Embeddings (semantic-search-mcp) | Test workflows |
| `GEMINI_PROXY_ENDPOINT` | Gemini proxy | Test workflows |
| `PROD_REPO_URL` | Production repository | Release workflow |
| `PROD_DEPLOY_KEY` | Deploy SSH key | Release workflow |

**Never commit secrets!** Use `${{ secrets.SECRET_NAME }}` in workflows.

## Integration with semantic-search-mcp

This repository automates development of the main project:
- **Location**: `/Users/artemgusarov/Downloads/PROJECTS/semantic-search-mcp`
- **GitHub**: Linked via Linear webhooks and GitHub Actions
- **Testing**: Workflows run tests against semantic-search-mcp codebase
- **Deployment**: Release pipeline builds and deploys semantic-search-mcp

When working on workflows, you may need to reference the main codebase for:
- Test commands (`pytest -v`)
- Build process
- MCP server startup (`python -m src.main`)
- Dependencies (`pip install -e ".[dev]"`)

## Key Design Patterns

### 1. Router Pattern
Single entry point (`router` job) that:
- Filters bot events
- Determines action type
- Selects role & model
- Performs idempotency checks
- Outputs decision for downstream jobs

### 2. Multi-layered Prompts
System prompts are composed from multiple sources:
```bash
BASE + ROLE + LINEAR_GUIDE + GITHUB_MCP_GUIDE + PROGRESS_INSTRUCTIONS
```

This allows:
- Reusable base rules across all roles
- Role-specific behavior
- Integration-specific guidelines
- Task-specific metadata

### 3. Idempotency via PR/Branch Checks
Before starting work, check if:
- PR exists with Linear ID in title/body
- Branch exists matching Linear ID pattern
- Another run is processing same task

Skip duplicate work, notify user.

### 4. Serialized Concurrency
Use `cancel-in-progress: false` to:
- Queue multiple runs of same task
- Prevent race conditions
- Avoid self-cannibalization (webhook + comment arriving simultaneously)

### 5. MCP-First Approach
Prefer MCP tools over CLI commands:
- ✅ `mcp__github_comment__update_claude_comment` instead of `gh issue comment`
- ✅ `mcp__web-search-prime__webSearchPrime` instead of curl + jq
- ✅ `linear-server` MCP instead of GraphQL requests

Rationale: MCP provides higher-level abstractions, better error handling, and consistent interface.

## Monitoring & Debugging

### View Workflow Runs
```bash
# List recent runs
gh run list --workflow=unified-ai-pipeline.yml --limit=20

# Watch live run
gh run watch <run-id>

# View logs
gh run view <run-id> --log

# Download artifacts
gh run download <run-id>
```

### Check Linear ↔ GitHub Sync
```bash
# View sync workflow runs
gh run list --workflow=linear-sync.yml --limit=10

# Check status sync
gh run list --workflow=sync-statuses.yml --limit=5
```

### Debug MCP Servers
```bash
# Test MCP server manually
npx -y @anthropic-ai/linear-mcp

# Check MCP server logs in workflow
gh run view <run-id> --log | grep -i "mcp"
```

## Performance Optimization

### NPM Cache
Workflows cache NPX packages to speed up MCP server startup by 3-5x:
```yaml
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-npx-mcp-${{ hashFiles('.github/mcp-servers.json') }}
```

### Model Selection
- **haiku (glm-4.5-air)**: 2-3x faster for simple tasks (reviews, responses, bug fixes)
- **sonnet (glm-4.7)**: Balanced for architecture and complex features
- **opus (glm-4.7)**: Research and exploration (same as sonnet in current setup)

### Concurrency Limits
MCP servers have `maxConcurrency` settings to prevent rate limiting:
- Linear: 5
- GitHub: 5
- zai-mcp-server: 5
- web-search-prime: 3
- web-reader: 3
- zread: 2

## Future Automation Opportunities

See `.github/AUTOMATION_OPPORTUNITIES.md` for detailed plans:

1. **Auto-delete merged branches** (High priority)
2. **Auto-update dependencies** (Urgent)
3. **Auto-release notes** (High priority)
4. **Auto-code review on PR** (Medium priority)
5. **Improved Linear sync** (bi-directional)
6. **Auto-sprint planning** (Low priority)
7. **Stale PR reminders** (Low priority)
8. **Weekly reports** (Low priority)
9. **Auto-triage issues** (Medium priority)
10. **Security checks on PRs** (Urgent)

## Getting Help

- **Workflow issues**: Check `.github/workflows/*.yml` and workflow run logs
- **System prompt issues**: Review `.github/system-prompts/*.md`
- **MCP issues**: Test servers locally with `npx`, check `.github/mcp-servers.json`
- **Configuration**: See `.github/workflow-config.yml` for reference values
- **Automation ideas**: See `.github/AUTOMATION_OPPORTUNITIES.md`

When asking Claude Code for help, reference specific workflow names and job names for faster debugging.
