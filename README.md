# russianoracle-dev/.github-actions

Org-level composite actions and workflows for CI/CD pipelines.

## Docker Images

### `ghcr.io/russianoracle-dev/claude-runner:latest`

Pre-built Docker image with AI runner CLI + plugins (superpowers, feature-dev, serena).
Eliminates ~60-90s of runtime installation on every AI job.

| Scenario | Time |
|----------|------|
| Cold (no cache) | ~30s (pull from GHCR) |
| **Warm (cache hit)** | **~3-5s** |

**Rebuild workflow:** `.github/workflows/build-claude-runner.yml`
- Triggers: weekly schedule (Mon 04:00 UTC), `push` to `docker/claude-runner.dockerfile`, `workflow_dispatch`
- Publishes: `latest` + `sha-<short>` + `weekly-YYYY-MM-DD` tags

---

## Actions

### `install-claude-plugins`

Extracts the CLI binary and plugins from the pre-built Docker image.
Requires a prior `docker/login-action` step to authenticate with GHCR.

```yaml
- name: "🔑 Login to GHCR"
  uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}

- name: "🔌 Install plugins"
  id: plugins
  uses: russianoracle-dev/.github-actions/.github/actions/install-claude-plugins@main
  # Optional: pin to specific image tag
  # with:
  #   image: "ghcr.io/russianoracle-dev/claude-runner:sha-abc1234"

- uses: anthropics/claude-code-action@v1
  with:
    path_to_claude_code_executable: ${{ steps.plugins.outputs.claude_path }}
```

**Inputs:**

| Input | Default | Description |
|-------|---------|-------------|
| `image` | `ghcr.io/russianoracle-dev/claude-runner:latest` | Docker image to pull |

**Outputs:**

| Output | Description |
|--------|-------------|
| `claude_path` | Path to extracted CLI binary (`/tmp/claude-runner`) |

---

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
