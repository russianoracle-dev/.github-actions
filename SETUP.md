# Setup Guide

## ✅ Completed Steps

1. **✅ Repository Created**: `https://github.com/russianoracle/claude-code-actions`
2. **✅ Code Pushed**: Initial commits with workflows and documentation
3. **✅ Workflows Enabled**: 13 GitHub Actions workflows are active
4. **✅ Partial Secrets**: 2 of 7 secrets configured (GEMINI_API_KEY, GEMINI_PROXY_ENDPOINT)

## ⚠️ Remaining Manual Steps

### 1. Configure Missing Secrets

You need to manually add these secrets from `semantic-search-mcp` repository:

| Secret | Purpose | How to Get |
|--------|---------|-----------|
| `ANTHROPIC_API_KEY` | AI API access | Copy from semantic-search-mcp secrets |
| `ANTHROPIC_BASE_URL` | AI API endpoint | Copy from semantic-search-mcp secrets |
| `LINEAR_API_KEY` | Linear integration | Copy from semantic-search-mcp secrets |
| `PROD_REPO_URL` | Production repo URL | Copy from semantic-search-mcp secrets |
| `PROD_DEPLOY_KEY` | SSH deploy key | Copy from semantic-search-mcp secrets |

**Option A: Copy via GitHub UI**

1. **Source (semantic-search-mcp)**:
   ```
   https://github.com/russianoracle/semantic-search-mcp/settings/secrets/actions
   ```

2. **Target (claude-code-actions)**:
   ```
   https://github.com/russianoracle/claude-code-actions/settings/secrets/actions
   ```

3. **Steps**:
   - Open source repository secrets
   - Copy each secret value (GitHub shows `Update` button - click to see)
   - Paste into target repository

**Option B: Use CLI (if you have values)**

```bash
# Set secret via stdin (most secure)
echo -n "secret-value" | gh secret set SECRET_NAME \
  --repo russianoracle/claude-code-actions \
  --body -

# Example:
echo -n "sk-ant-..." | gh secret set ANTHROPIC_API_KEY \
  --repo russianoracle/claude-code-actions \
  --body -
```

**Option C: Use helper script**

```bash
# Interactive setup (will prompt for each value)
./scripts/setup-secrets.sh
```

### 2. Verify Setup

After adding secrets, verify everything is configured:

```bash
# Check all secrets are set
gh secret list --repo russianoracle/claude-code-actions

# Run verification script
./scripts/quick-setup.sh
```

Expected output:
```
Secrets:    ✅ 7 configured, 0 missing
```

### 3. Test Automation

Create a test issue to verify workflows:

```bash
gh issue create \
  --repo russianoracle/claude-code-actions \
  --title '[TEST] Verify AI automation' \
  --body 'Test issue for verifying automation setup.

## Expected Behavior
- [ ] Workflow should trigger on @claude mention
- [ ] AI agent should respond to this issue
- [ ] Response should appear as comment

@claude please respond to confirm automation works' \
  --label test

# Wait ~30 seconds, then check for response:
gh issue list --repo russianoracle/claude-code-actions --label test
```

**Expected result**: AI agent responds with confirmation within 1-2 minutes.

### 4. Enable Linear Integration (Optional)

If you want Linear → GitHub sync:

1. **Get webhook URL**:
   ```
   https://github.com/russianoracle/claude-code-actions
   ```

2. **Configure in Linear**:
   - Settings → Webhooks → Create webhook
   - URL: `https://api.github.com/repos/russianoracle/claude-code-actions/dispatches`
   - Secret: Use `LINEAR_API_KEY` value
   - Events: Issue created, Issue updated, Issue status changed

3. **Test**:
   - Create Linear issue
   - Change status to "In Progress"
   - Verify GitHub Actions workflow triggers

### 5. Link to semantic-search-mcp

Update `semantic-search-mcp` repository to reference this automation repo:

```bash
cd /Users/artemgusarov/Downloads/PROJECTS/semantic-search-mcp

# Add reference in README.md
echo "

## Automation

This project uses automated CI/CD via [claude-code-actions](https://github.com/russianoracle/claude-code-actions).

- **Auto-implementation**: Change Linear status to 'In Progress'
- **Code review**: Add label \`needs-ai-review\` to PR
- **Release**: Comment \`@claude release\` on issue
" >> README.md

git add README.md
git commit -m "docs: add reference to automation repository"
git push
```

## Verification Checklist

Use this checklist to verify complete setup:

- [ ] All 7 secrets configured in GitHub
- [ ] `./scripts/quick-setup.sh` shows all ✅
- [ ] Test issue with `@claude` mention gets response
- [ ] Workflows visible at `https://github.com/russianoracle/claude-code-actions/actions`
- [ ] Linear webhook configured (optional)
- [ ] semantic-search-mcp references automation repo (optional)

## Next Steps After Setup

Once setup is complete:

### Daily Usage

```bash
# Create issue and trigger implementation
gh issue create \
  --repo russianoracle/semantic-search-mcp \
  --title '[FEATURE] Add new capability' \
  --body 'Description...' \
  --label feature,claude-implement

# Or via Linear:
# 1. Create Linear issue
# 2. Set status to "In Progress"
# 3. Automation creates branch + PR automatically
```

### Monitor Workflow Runs

```bash
# List recent runs
gh run list --repo russianoracle/claude-code-actions --limit 10

# Watch live run
gh run watch --repo russianoracle/claude-code-actions

# View failed runs
gh run list --status failure --limit 5
```

### Customize Workflows

Edit workflow files as needed:

```bash
# Edit main AI pipeline
vim .github/workflows/unified-ai-pipeline.yml

# Update timeouts
vim .github/workflow-config.yml

# Modify system prompts
vim .github/system-prompts/implementer.md

# Add new MCP server
vim .github/mcp-servers.json
```

## Troubleshooting

### Secrets Not Working

```bash
# Verify secret exists
gh secret list --repo russianoracle/claude-code-actions

# Check workflow logs for errors
gh run view <run-id> --log | grep -i "secret\|error"

# Re-set secret
echo -n "new-value" | gh secret set SECRET_NAME \
  --repo russianoracle/claude-code-actions \
  --body -
```

### Workflow Not Triggering

```bash
# Check if workflow is enabled
gh workflow list --repo russianoracle/claude-code-actions

# View recent runs (including failed)
gh run list --limit 20

# Check webhook deliveries (for Linear integration)
# Visit: Settings → Webhooks → Recent Deliveries
```

### AI Agent Not Responding

```bash
# Check ANTHROPIC_API_KEY is set
gh secret list | grep ANTHROPIC

# View workflow run logs
gh run view <run-id> --log

# Check quota usage
# Visit: Settings → Billing → Usage
```

## Support

- **Documentation**: See `CLAUDE.md` for comprehensive guide
- **Workflow Reference**: See `README.md` for usage examples
- **Automation Ideas**: See `.github/AUTOMATION_OPPORTUNITIES.md`

## Security Notes

**⚠️ Important**:
- Never commit secrets to git
- Use `${{ secrets.* }}` in workflows
- Rotate secrets periodically
- Use minimal permissions for tokens
- Monitor workflow runs for suspicious activity

**Best Practices**:
- Review workflow changes in PRs
- Test in separate repo before deploying
- Keep secrets in GitHub, not in code
- Use separate keys for dev/prod
- Enable 2FA on GitHub account
