# HANDOFF — Runner Infrastructure

**Date:** 2026-03-09 17:55
**Status:** ✅ INFRASTRUCTURE READY

## Infrastructure Summary

### Self-Hosted Runners (Vultr)

| Server | IP | User | Runners Count |
|--------|-----|------|---------------|
| Vultr Amsterdam | 95.179.136.242 | openclaw | 2 |

**Runner Names:** `vultr-org-runner-1`, `vultr-org-runner-2`
**Labels:** `self-hosted`, `Linux`, `X64`

### Tools Installed (for openclaw user)

| Tool | Version | Path |
|------|---------|------|
| actionlint | 1.7.11 | /home/openclaw/gh-tools/bin/actionlint |
| yamllint | 1.38.0 | /home/openclaw/gh-tools/bin/yamllint |
| check-jsonschema | 0.37.0 | /home/openclaw/gh-tools/bin/check-jsonschema |

### Critical Issue

**Problem:** Runners execute as `github-runner` user, tools installed for `openclaw`
**Solution:** Workflows use full paths: `/home/openclaw/gh-tools/bin/actionlint`

### SSH Connection

```bash
ssh openclaw  # Uses ~/.ssh/config alias
```

### Workflow Created

`.github/workflows/validate-workflows.yml` - Validates all workflows on push/PR

## Next Steps

1. **Get sudo access** to install tools system-wide or for github-runner user
2. **Alternative:** Create Docker image with tools pre-installed
3. **Restart runners** after adding tools to .env file

## Commands

```bash
# Check runners
gh api orgs/russianoracle-dev/actions/runners | jq '.runners[] | {name, status}'

# SSH to server
ssh openclaw

# Check tools
ls -la /home/openclaw/gh-tools/bin/

# Run validation locally
/home/openclaw/gh-tools/bin/actionlint .github/workflows/*.yml
```
