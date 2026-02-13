# Linear MCP Integration Guidelines

## Available Linear MCP Tools

You have access to the `linear-server` MCP server with the following tools:

### Issue Management
- `mcp__linear-server__get_issue` - Get issue details by ID (e.g., "SMNTX-91")
- `mcp__linear-server__list_issues` - List issues with filters
- `mcp__linear-server__create_issue` - Create new issue
- `mcp__linear-server__update_issue` - Update issue (status, assignee, etc.)

### Comments
- `mcp__linear-server__list_comments` - List comments on an issue
- `mcp__linear-server__create_comment` - Add comment to issue

### Attachments
- `mcp__linear-server__get_attachment` - Get attachment details
- `mcp__linear-server__create_attachment` - Create attachment (for PR links, files)
- `mcp__linear-server__delete_attachment` - Delete attachment

### Documents
- `mcp__linear-server__get_document` - Get document by ID
- `mcp__linear-server__list_documents` - List project documents
- `mcp__linear-server__create_document` - Create new document
- `mcp__linear-server__update_document` - Update document content

### Projects & Cycles
- `mcp__linear-server__list_projects` - List all projects
- `mcp__linear-server__get_project` - Get project details
- `mcp__linear-server__list_cycles` - List sprint cycles
- `mcp__linear-server__list_milestones` - List milestones

### Team & Users
- `mcp__linear-server__list_teams` - List teams
- `mcp__linear-server__get_team` - Get team details
- `mcp__linear-server__list_users` - List team members
- `mcp__linear-server__get_user` - Get user details

### Labels & Statuses
- `mcp__linear-server__list_issue_labels` - List available labels
- `mcp__linear-server__create_issue_label` - Create new label
- `mcp__linear-server__list_issue_statuses` - List workflow states
- `mcp__linear-server__get_issue_status` - Get status details

## State Names Reference

Linear workflow states for this project:

| State | Type | Use Case |
|-------|------|----------|
| `Backlog` | backlog | Not started, low priority |
| `Todo` | unstarted | Ready for work |
| `In Progress` | started | Currently being worked on |
| `In Review` | started | PR created, awaiting review |
| `Done` | completed | Work completed successfully |
| `Cancelled` | canceled | Work abandoned |

## Best Practices

### Updating Issue Status

```python
# Correct: Use state name
mcp__linear-server__update_issue(
    issue_id="SMNTX-91",
    state="In Review"
)

# Also supported: Use state ID
mcp__linear-server__update_issue(
    issue_id="SMNTX-91",
    state_id="abc123-state-id"
)
```

### Creating Comments

```python
# Rich formatting with markdown
mcp__linear-server__create_comment(
    issue_id="SMNTX-91",
    body="""## PR Created

**Link:** [PR #123](https://github.com/repo/pull/123)

### Changes
- Added new feature X
- Fixed bug Y
- Updated tests

**Status:** Ready for review
"""
)
```

### Creating Attachments for PRs

```python
# Link PR to Linear issue
mcp__linear-server__create_attachment(
    issue_id="SMNTX-91",
    title="Pull Request #123",
    url="https://github.com/repo/pull/123",
    subtitle="feat: implement feature X"
)
```

### Working with Relations

When checking dependencies:

```python
# Get issue with relations
issue = mcp__linear-server__get_issue(issue_id="SMNTX-91")
# Check issue.blockedBy for blocking issues
# Check issue.blocks for issues this blocks
```

### Sprint/Cycle Operations

```python
# Get current cycle issues
cycles = mcp__linear-server__list_cycles(team_id="team-id")
current_cycle = [c for c in cycles if c.status == "active"][0]
issues = mcp__linear-server__list_issues(cycle_id=current_cycle.id)
```

## Comment Formatting Guidelines

### Sync Markers

Use `[auto-sync]` marker to identify automated comments:

```markdown
[auto-sync] PR Created: [Title](url)
[auto-sync] PR Merged! Implementation complete.
[auto-sync] PR Closed without merge.
```

### Status Update Comments

```markdown
[auto-sync] Status changed: In Progress -> In Review

**Trigger:** PR opened
**Link:** [PR #123](url)
```

### Emoji Usage

| Event | Emoji |
|-------|-------|
| PR Created | :link: |
| PR Merged | :white_check_mark: |
| PR Closed | :x: |
| Review Approved | :thumbsup: |
| Build Started | :rocket: |
| Build Failed | :x: |
| Blocked | :no_entry: |
| Unblocked | :unlock: |

## Error Handling

Always handle cases where:
1. Issue doesn't exist (`issue not found`)
2. State doesn't exist in team workflow
3. User doesn't have permissions
4. Rate limiting (Linear has 1500 req/hour limit)

```python
try:
    result = mcp__linear-server__update_issue(...)
    if not result.success:
        # Log error but don't fail workflow
        print(f"Linear update failed: {result.error}")
except Exception as e:
    print(f"Linear API error: {e}")
    # Continue with other operations
```

## Integration Patterns

### GitHub PR -> Linear Status

```
PR opened -> "In Review"
PR merged -> "Done"
PR closed (no merge) -> Comment only, no status change
```

### Linear Status -> GitHub Actions

```
"In Progress" -> Trigger implement workflow
"Released" -> Trigger release workflow
"Cancelled" -> Close related PR
```

### Bi-directional Sync

Avoid infinite loops by:
1. Using `[auto-sync]` marker to identify bot comments
2. Checking current state before updating
3. Using idempotency keys for actions
