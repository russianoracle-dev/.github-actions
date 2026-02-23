# russianoracle-dev/.github-actions

Org-level composite actions for CI/CD pipelines.

## Actions

### `setup-claude-pipeline`
Loads system prompts and creates MCP config for `claude-code-action`.

```yaml
- uses: russianoracle-dev/.github-actions/.github/actions/setup-claude-pipeline@main
  with:
    role: ${{ needs.router.outputs.role }}
    action: ${{ needs.router.outputs.action }}
    issue_number: ${{ needs.router.outputs.issue_number }}
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    github_token: ${{ secrets.GITHUB_TOKEN }}
    is_dispatch: ${{ github.event_name == 'repository_dispatch' }}
```

### `install-claude-plugins`
Installs Claude Code CLI and plugins idempotently.

```yaml
- uses: russianoracle-dev/.github-actions/.github/actions/install-claude-plugins@main
  id: claude-setup
  with:
    claude_version: "2.1.6"

- uses: anthropics/claude-code-action@v1
  with:
    path_to_claude_code_executable: ${{ steps.claude-setup.outputs.claude_path }}
```

### `setup-git-credentials`
Configures git credentials for pushing to GitHub.

```yaml
- uses: russianoracle-dev/.github-actions/.github/actions/setup-git-credentials@main
  with:
    github_token: ${{ secrets.GH_TOKEN }}
```

### `cleanup-claude-pipeline`
Removes temporary files created during pipeline execution.

```yaml
- name: Cleanup
  if: always()
  uses: russianoracle-dev/.github-actions/.github/actions/cleanup-claude-pipeline@main
```
