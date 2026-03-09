# Self-Hosted Runner Setup

## Servers

| Server | IP | User | Runners |
|--------|-----|------|---------|
| Vultr Amsterdam | 95.179.136.242 | openclaw | vultr-org-runner-1, vultr-org-runner-2 |

## Users on Server

| User | Purpose | Home | Tools Location |
|------|---------|------|------------------|
| openclaw | Main user | /home/openclaw | /home/openclaw/gh-tools/bin/ |
| github-runner | GitHub Actions runner | /home/github-runner | NONE (uses openclaw's tools) |

## Installed Tools (via openclaw)

| Tool | Version | Location |
|------|---------|----------|
| actionlint | 1.7.11 | /home/openclaw/gh-tools/bin/actionlint |
| yamllint | 1.38.0 | /home/openclaw/gh-tools/bin/yamllint |
| check-jsonschema | 0.37.0 | /home/openclaw/gh-tools/bin/check-jsonschema |

## SSH Access

```bash
ssh openclaw  # Connect to server
```

## Workflow Configuration

Workflows must use full path to tools:

```yaml
env:
  TOOLS_PATH: /home/openclaw/gh-tools/bin

steps:
  - run: $TOOLS_PATH/actionlint .github/workflows/*.yml
```

## Runner Services

```bash
# Check status
systemctl status actions.runner.russianoracle-dev.vultr-org-runner-1
systemctl status actions.runner.russianoracle-dev.vultr-org-runner-2

# Restart (requires sudo)
sudo systemctl restart actions.runner.russianoracle-dev.vultr-org-runner-1
```

## Important Notes

1. **NO SUDO ACCESS** for openclaw user - need password
2. **Runners run as `github-runner` user** - cannot access openclaw's home directly
3. **Workaround** - Use full paths in workflows: `/home/openclaw/gh-tools/bin/actionlint`
4. **To add tools for github-runner** - Need sudo or login as github-runner
