# claude-code-actions

**CI/CD automation framework** for [semantic-search-mcp](https://github.com/russianoracle/semantic-search-mcp) using GitHub Actions and AI agents.

## Overview

This repository contains GitHub Actions workflows and system prompts that enable fully automated software development lifecycle:
- 🤖 **Auto-implementation** from Linear/GitHub issues
- 🔍 **AI-powered code review**
- 🧪 **Automated testing** (unit, integration)
- 🚀 **Release pipeline** to production
- 🔄 **Linear ↔ GitHub sync**

**Architecture**: Role-based AI agents (architect, debugger, implementer, reviewer) orchestrated through GitHub Actions with MCP server integration.

## Quick Start

### 1. Clone & Setup

```bash
# Clone repository
git clone https://github.com/russianoracle/claude-code-actions.git
cd claude-code-actions

# Review configuration
cat CLAUDE.md  # Comprehensive project guide
cat .github/workflow-config.yml  # Reference values
```

### 2. Configure Secrets

Required secrets for workflows:

| Secret | Purpose | Required For |
|--------|---------|--------------|
| `ANTHROPIC_API_KEY` | AI API access | All AI workflows |
| `ANTHROPIC_BASE_URL` | API endpoint | All AI workflows |
| `LINEAR_API_KEY` | Linear integration | Sync workflows |
| `GEMINI_API_KEY` | Embeddings | Test workflows |
| `GEMINI_PROXY_ENDPOINT` | Gemini proxy | Test workflows |
| `PROD_REPO_URL` | Production repo | Release workflow |
| `PROD_DEPLOY_KEY` | Deploy SSH key | Release workflow |

**Setup via GitHub UI**:
```bash
# Open secrets settings
gh repo view -w --settings
# Navigate to: Settings → Secrets and variables → Actions → New repository secret
```

**Or use helper script**:
```bash
chmod +x scripts/setup-secrets.sh
./scripts/setup-secrets.sh
```

### 3. Enable Workflows

```bash
# List all workflows
gh workflow list

# Enable specific workflow
gh workflow enable unified-ai-pipeline.yml

# Enable all workflows
gh workflow list --json path -q '.[].path' | \
  xargs -I {} gh workflow enable {}
```

### 4. Test Integration

Create a test issue to verify setup:

```bash
# Create test issue
gh issue create \
  --title "[TEST] Verify automation setup" \
  --body "Test issue for verifying AI automation.

## Tasks
- [ ] Verify workflows are enabled
- [ ] Test @claude mention
- [ ] Check Linear sync

/cc @claude" \
  --label "test"

# Mention AI in comment
gh issue comment <issue-number> -b "@claude please respond to verify automation works"
```

## Project Structure

```
claude-code-actions/
├── .github/
│   ├── workflows/              # 15 GitHub Actions workflows
│   │   ├── unified-ai-pipeline.yml  # Main AI orchestrator
│   │   ├── ci-pipeline.yml          # Continuous Integration
│   │   ├── cd-pipeline.yml          # Continuous Deployment
│   │   ├── linear-sync.yml          # Linear → GitHub sync
│   │   ├── pr-linear-sync.yml       # GitHub → Linear sync
│   │   ├── claude-code-review.yml   # AI code review
│   │   ├── integration-tests.yml    # Heavy tests
│   │   ├── test-pipeline.yml        # Test orchestration
│   │   ├── dependency-tracker.yml   # Dependency monitoring
│   │   ├── release-notes.yml        # Auto release notes
│   │   ├── sprint-planning.yml      # Sprint planning
│   │   ├── sync-statuses.yml        # Status sync
│   │   └── cleanup.yml              # Branch cleanup
│   ├── system-prompts/         # Role-based AI prompts
│   │   ├── _base.md                 # Base prompt (all roles)
│   │   ├── architect.md             # Research & architecture
│   │   ├── debugger.md              # Bug fixing
│   │   ├── implementer.md           # Feature implementation
│   │   ├── reviewer.md              # Code review
│   │   ├── responder.md             # Quick responses
│   │   ├── linear-integration.md    # Linear workflows
│   │   └── github-mcp-usage.md      # GitHub MCP guide
│   ├── claude-settings.json    # Model mapping & permissions
│   ├── mcp-servers.json        # MCP servers config
│   ├── workflow-config.yml     # Reference values & quotas
│   └── *.md                    # Documentation
├── scripts/
│   └── setup-secrets.sh        # Helper for secrets setup
├── CLAUDE.md                   # Comprehensive guide
├── README.md                   # This file
└── .gitignore
```

## Workflows Overview

### Core Automation

**Unified AI Pipeline** (`unified-ai-pipeline.yml`)
- **Triggers**: @claude mentions, labels, Linear webhooks
- **Actions**: respond, review, implement, release
- **Features**: Idempotency, per-task concurrency, role-based routing

### CI/CD

**CI Pipeline** (`ci-pipeline.yml`)
- Run tests on every push/PR
- Lint and type checking
- Fast feedback loop

**CD Pipeline** (`cd-pipeline.yml`)
- Deploy on tag creation
- Build release artifacts
- Push to production repo

### Linear Integration

**Linear Sync** (`linear-sync.yml`)
- Sync status changes: Todo → In Progress → Done
- Auto-create GitHub issues from Linear
- Bi-directional linking

**PR Linear Sync** (`pr-linear-sync.yml`)
- Update Linear when PR is merged
- Link PRs to Linear issues
- Status synchronization

### Development Tools

**Code Review** (`claude-code-review.yml`)
- AI-powered code review on demand
- Triggered by `needs-ai-review` label
- Fast reviews with haiku model

**Integration Tests** (`integration-tests.yml`)
- Heavy tests with Qdrant
- Triggered by `run-integration-tests` label
- Runs in isolated environment

## Usage Examples

### Auto-implement from Linear

1. Create Linear issue with status "Todo"
2. Add labels for role selection:
   - `research` → architect (opus model)
   - `bug` → debugger (haiku model)
   - `feature` → implementer (haiku model)
3. Change status to "In Progress"
4. **Automatic**: Workflow triggers, creates feature branch, implements, creates PR

### Manual implementation trigger

```bash
# Via label
gh issue edit <issue-number> --add-label claude-implement

# Via comment
gh issue comment <issue-number> -b "@claude implement"

# Via assignment
gh issue edit <issue-number> --add-assignee claude
```

### Code review

```bash
# Request review
gh pr edit <pr-number> --add-label needs-ai-review

# Or comment
gh pr comment <pr-number> -b "@claude review"
```

### Release

```bash
# Via comment on issue/PR
gh issue comment <issue-number> -b "@claude release"

# Or via PR label
gh pr edit <pr-number> --add-label release
```

## Configuration

### Model Selection

**File**: `.github/claude-settings.json`

```json
{
  "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-4.7",
  "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-4.7",
  "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.5-air"
}
```

**Performance**: haiku (glm-4.5-air) is 2-3x faster for simple tasks.

### Workflow Timeouts

**File**: `.github/workflow-config.yml`

```yaml
timeouts:
  mention: 30           # @claude responses
  label: 45             # claude-implement label
  assign: 45            # claude assignment
  linear_implement: 60  # Linear → implementation
  code_review: 20       # PR code review
  integration_tests: 15 # Heavy tests
```

### MCP Servers

**File**: `.github/mcp-servers.json`

Available integrations:
- `linear-server` — Linear API
- `github-server` — GitHub API
- `zai-mcp-server` — Screenshot analysis
- `web-search-prime` — Web search
- `web-reader` — Webpage reading
- `zread` — GitHub repo search

## Monitoring

### View Workflow Runs

```bash
# List recent runs
gh run list --workflow=unified-ai-pipeline.yml --limit=10

# Watch live run
gh run watch

# View logs
gh run view <run-id> --log

# Download artifacts
gh run download <run-id>
```

### Check Linear Sync

```bash
# Linear → GitHub sync
gh run list --workflow=linear-sync.yml --limit=5

# GitHub → Linear sync
gh run list --workflow=pr-linear-sync.yml --limit=5

# Status sync (hourly)
gh run list --workflow=sync-statuses.yml --limit=5
```

### Debug Issues

```bash
# Check workflow syntax
gh workflow view unified-ai-pipeline.yml

# Re-run failed job
gh run rerun <run-id>

# Cancel stuck run
gh run cancel <run-id>
```

## Performance Optimization

### NPM Cache

Workflows cache NPX packages (3-5x faster startup):
```yaml
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-npx-mcp-${{ hashFiles('.github/mcp-servers.json') }}
```

### Concurrency Limits

MCP servers have rate limiting protection:
- Linear/GitHub/zai: 5 concurrent requests
- web-search/web-reader: 3 concurrent requests
- zread: 2 concurrent requests

### Quota Management

Free tier: **2000 minutes/month**
- Recommended daily limit: **66 minutes**
- Track usage: Settings → Actions → Usage

## Development

### Adding New Workflow

1. Create workflow file in `.github/workflows/`
2. Add concurrency group
3. Document timeout in `.github/workflow-config.yml`
4. Test with `gh workflow run` or `act`
5. Update `CLAUDE.md` and `README.md`

### Modifying System Prompts

1. Edit prompt in `.github/system-prompts/`
2. Test with relevant workflow
3. Verify AI agent behavior
4. Update role mapping in `workflow-config.yml` if needed

### Updating MCP Servers

1. Edit `.github/mcp-servers.json`
2. Update cache key in workflows
3. Test locally: `npx -y @package/name`
4. Verify in workflow runs

## Troubleshooting

### Workflow Not Triggering

**Check**:
```bash
# Verify workflow is enabled
gh workflow view unified-ai-pipeline.yml

# Check workflow run history
gh run list --workflow=unified-ai-pipeline.yml --limit=20

# View failed runs
gh run list --status=failure --limit=10
```

**Common Issues**:
- Bot comments are filtered (by design)
- Idempotency check skipped duplicate work
- Label doesn't match trigger pattern
- Secrets not configured

### AI Agent Not Responding

**Check**:
```bash
# View workflow run logs
gh run view <run-id> --log | grep -i "error\|fail"

# Check MCP server startup
gh run view <run-id> --log | grep -i "mcp"

# Verify secrets are set
gh secret list
```

**Common Issues**:
- `ANTHROPIC_API_KEY` not set or invalid
- MCP server timeout (increase timeout in `mcp-servers.json`)
- Model quota exceeded
- Network issues with MCP servers

### Linear Sync Issues

**Check**:
```bash
# View sync logs
gh run list --workflow=linear-sync.yml --limit=5

# Check webhook deliveries (GitHub UI)
# Settings → Webhooks → Recent Deliveries
```

**Common Issues**:
- `LINEAR_API_KEY` not set or invalid
- Webhook not configured in Linear
- Status mapping mismatch
- Network timeout

## Contributing

This is a private automation framework for semantic-search-mcp project.

**Workflow**:
1. Create feature branch: `feature/<description>`
2. Update workflows/prompts/config
3. Test locally or in separate repo
4. Create PR with clear description
5. Merge after review

## Related Projects

- **semantic-search-mcp** — Main codebase being automated
- **Linear** — Task management integration

## License

Private - Internal automation framework

## Support

For issues or questions:
- Check `CLAUDE.md` for detailed documentation
- View workflow logs: `gh run view <run-id> --log`
- Check automation opportunities: `.github/AUTOMATION_OPPORTUNITIES.md`
