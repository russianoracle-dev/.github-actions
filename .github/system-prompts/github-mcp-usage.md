# GitHub MCP Usage Guide

## 🎯 Golden Rule

**In Claude Jobs (claude-implement, claude-respond): Use GitHub MCP for ALL GitHub operations**

**gh CLI: ONLY for (1) router job quick checks OR (2) local file reading without clone**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Tool Separation

### Router Job (Bash) → Uses gh CLI
- **Purpose:** Quick idempotency checks BEFORE Claude runs
- **Tool:** `gh pr list`, `gh run list` (bash + jq)
- **Why:** Fast, lightweight checks to decide if Claude should run

### Claude Jobs (Python) → Use GitHub MCP
- **Purpose:** Actual GitHub operations during implementation
- **Tool:** `github_pr.*`, `github_issue.*` (Python API)
- **Why:** Structured data, better error handling, cleaner code

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## ✅ Use GitHub MCP Tools In Claude Jobs

### Available MCP Tools

You have access to these GitHub MCP tools in this workflow:

1. **github_pr.list(state, base, head)** - List pull requests
2. **github_issue.create_comment(issue_number, body)** - Comment on issues
3. **github_issue.create(title, body, labels)** - Create issues
4. **github_pr.create(title, body, head, base)** - Create pull requests
5. **github_issue.update(issue_number, ...)** - Update issues
6. **github_pr.merge(pull_number, merge_method)** - Merge PRs

### When to Use Each Tool

#### 1. Idempotency Checks - Check for Existing PRs

**Before creating a PR, check if one already exists:**

```python
# List all open PRs
prs = github_pr.list(state="open")

# Check for Linear ID in title (e.g., [SMNTX-93])
for pr in prs:
    if f"[{LINEAR_ID}]" in pr.title or f"({LINEAR_ID})" in pr.title:
        existing_pr = pr.number
        break

# Check for issue reference in title
if not existing_pr and ISSUE_NUM:
    for pr in prs:
        if f"#{ISSUE_NUM}" in pr.title:
            existing_pr = pr.number
            break

# Check for issue reference in body (closes #123)
if not existing_pr and ISSUE_NUM:
    for pr in prs:
        if f"closes #{ISSUE_NUM}" in pr.body or f"fixes #{ISSUE_NUM}" in pr.body:
            existing_pr = pr.number
            break
```

#### 2. Notify About Skipped Actions

**When skipping duplicate work, notify the issue:**

```python
github_issue.create_comment(
    owner="russianoracle",
    repo="semantic-search-mcp",
    issue_number=ISSUE_NUM,
    body="ℹ️ **Skipped duplicate action**\n\nThis task is already being processed."
)
```

#### 3. Create Pull Requests

**After implementing changes:**

```python
github_pr.create(
    owner="russianoracle",
    repo="semantic-search-mcp",
    title=f"[{LINEAR_ID}] {feature_title}",
    body=f"## Changes\n\n{description}\n\nCloses #{ISSUE_NUM}",
    head=BRANCH_NAME,
    base="main"
)
```

#### 4. Update Issue Status

**Add comments or close issues:**

```python
# Add progress comment
github_issue.create_comment(
    issue_number=ISSUE_NUM,
    body="✅ Implementation complete. PR: #{pr_number}"
)

# Close issue
github_issue.update(
    issue_number=ISSUE_NUM,
    state="closed"
)
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🚫 DO NOT Use gh CLI In Workflow

**In GitHub Actions, AVOID these gh CLI commands:**

- ❌ `gh pr list` → Use `github_pr.list()`
- ❌ `gh issue comment` → Use `github_issue.create_comment()`
- ❌ `gh issue create` → Use `github_issue.create()`
- ❌ `gh pr create` → Use `github_pr.create()`
- ❌ `gh api /repos/...` → Use GitHub MCP tools

**ALL GitHub operations in workflow should use GitHub MCP!**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📌 When gh CLI IS Acceptable

**gh CLI has TWO acceptable uses:**

### 1. Router Job Idempotency Checks (In GitHub Actions)

**Scenario:** The router job needs to quickly check if a PR/issue already exists BEFORE deciding whether to run Claude.

```bash
# Quick check in router job (bash)
ALL_PRS=$(gh pr list --repo $REPO --state open --json number,title,body)
EXISTING_PR=$(echo "$ALL_PRS" | jq -r '.[] | select(.title | test("\[SMNTX-93\]"; "i")) | .number')
```

**When to use:**
- ✅ Router job quick checks (before Claude runs)
- ✅ Deciding whether to skip duplicate work
- ✅ Fast, lightweight bash operations

**NOT for:**
- ❌ Claude job operations (use GitHub MCP)
- ❌ Creating PRs/issues from Claude (use GitHub MCP)

### 2. Local File Reading Without Clone (Outside GitHub Actions)

**Scenario:** You need to read a file from a repository but don't want to clone the entire repo.

```bash
# Read README.md without cloning (local development)
gh api /repos/russianoracle/semantic-search-mcp/contents/README.md

# Or via raw.githubusercontent.com
curl https://raw.githubusercontent.com/russianoracle/semantic-search-mcp/main/README.md
```

**When to use:**
- ✅ Local scripts outside GitHub Actions
- ✅ Quick file inspection without git clone
- ✅ Manual operations in terminal
- ✅ Debugging workflows (can copy command)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 💡 Quick Reference

| Operation | GitHub MCP | gh CLI (local only) |
|-----------|------------|-------------------|
| List PRs | `github_pr.list(state="open")` | `gh pr list` (local) |
| Check existing PR | Python loop over PRs | `gh pr list \| jq` (local) |
| Comment on issue | `github_issue.create_comment(...)` | `gh issue comment` (local) |
| Create PR | `github_pr.create(...)` | `gh pr create` (local) |
| Read file | ❌ Not available | ✅ `gh api /repos/.../contents/...` |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## ✅ Checklist for Claude Jobs

Before performing GitHub operations in Claude jobs:

- [ ] Am I using GitHub MCP tools? (github_pr.*, github_issue.*)
- [ ] Did I avoid gh CLI commands in Claude code?
- [ ] Is this a structured Python operation (not bash + jq)?
- [ ] Am I checking for existing PRs before creating?
- [ ] Am I providing clear comments when skipping work?

**Note:** Router job uses gh CLI for quick checks - that's OK! But in Claude jobs, use GitHub MCP.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🎯 Goal

**Claude jobs: GitHub MCP for GitHub operations**

**gh CLI: (1) Router job quick checks OR (2) Local file reading**

**Clear separation = no confusion! 🎯**

**Summary:**
- ✅ Router job (bash) → gh CLI for quick idempotency checks
- ✅ Claude jobs (Python) → GitHub MCP for all GitHub operations
- ✅ Local development → gh CLI for reading files without clone
