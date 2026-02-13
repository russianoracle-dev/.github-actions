# Setup Checklist

## ✅ Completed (Automated)

- [x] Create GitHub repository `russianoracle/claude-code-actions`
- [x] Copy `.github/` from semantic-search-mcp
- [x] Create CLAUDE.md (comprehensive guide)
- [x] Create README.md (quick start)
- [x] Create SETUP.md (setup instructions)
- [x] Create setup scripts (copy-secrets, quick-setup, setup-secrets)
- [x] Initialize git repository
- [x] Push to GitHub (3 commits)
- [x] Enable all workflows (13 workflows active)
- [x] Configure partial secrets (GEMINI_API_KEY, GEMINI_PROXY_ENDPOINT)

## ⏳ Remaining Manual Tasks (5-10 minutes)

### 1. Configure Missing Secrets

- [ ] Open source secrets: https://github.com/russianoracle/semantic-search-mcp/settings/secrets/actions
- [ ] Open target secrets: https://github.com/russianoracle/claude-code-actions/settings/secrets/actions
- [ ] Copy `ANTHROPIC_API_KEY`
- [ ] Copy `ANTHROPIC_BASE_URL`
- [ ] Copy `LINEAR_API_KEY`
- [ ] Copy `PROD_REPO_URL`
- [ ] Copy `PROD_DEPLOY_KEY`

**Quick CLI method** (if you have values):
```bash
echo -n "YOUR_VALUE" | gh secret set ANTHROPIC_API_KEY --repo russianoracle/claude-code-actions --body -
echo -n "YOUR_VALUE" | gh secret set ANTHROPIC_BASE_URL --repo russianoracle/claude-code-actions --body -
echo -n "YOUR_VALUE" | gh secret set LINEAR_API_KEY --repo russianoracle/claude-code-actions --body -
echo -n "YOUR_VALUE" | gh secret set PROD_REPO_URL --repo russianoracle/claude-code-actions --body -
echo -n "YOUR_VALUE" | gh secret set PROD_DEPLOY_KEY --repo russianoracle/claude-code-actions --body -
```

### 2. Verify Setup

- [ ] Run verification: `./scripts/quick-setup.sh`
- [ ] Confirm: "Secrets: ✅ 7 configured, 0 missing"
- [ ] Check workflows: `gh workflow list --repo russianoracle/claude-code-actions`

### 3. Test Automation

- [ ] Create test issue:
  ```bash
  gh issue create \
    --repo russianoracle/claude-code-actions \
    --title '[TEST] Verify automation' \
    --body '@claude please respond to verify automation works' \
    --label test
  ```
- [ ] Wait 1-2 minutes
- [ ] Check for AI response in issue comments
- [ ] Verify workflow run: `gh run list --limit 5`

### 4. Optional: Linear Integration

- [ ] Configure webhook in Linear:
  - URL: `https://api.github.com/repos/russianoracle/claude-code-actions/dispatches`
  - Events: Issue created, updated, status changed
- [ ] Test: Create Linear issue → change status to "In Progress"
- [ ] Verify: GitHub Actions workflow triggers

### 5. Optional: Link Repositories

- [ ] Add automation reference to semantic-search-mcp README
- [ ] Create cross-repository links
- [ ] Update semantic-search-mcp documentation

## 🎯 Success Criteria

All checkboxes above should be marked ✅ before considering setup complete.

**Expected results**:
- ✅ 7 secrets configured
- ✅ Test issue receives AI response
- ✅ Workflows running successfully
- ✅ No errors in `./scripts/quick-setup.sh`

## 📊 Quick Status Check

Run this command to verify everything:

```bash
./scripts/quick-setup.sh && \
echo "" && \
echo "═══════════════════════════════════════" && \
echo "✅ SETUP COMPLETE!" && \
echo "═══════════════════════════════════════" && \
echo "" && \
echo "Next: Create test issue to verify automation" && \
echo "  gh issue create --repo russianoracle/claude-code-actions \\" && \
echo "    --title '[TEST] Verify automation' \\" && \
echo "    --body '@claude please respond' \\" && \
echo "    --label test"
```

## 🔧 If Something Goes Wrong

### Secrets Not Working

```bash
# List current secrets
gh secret list --repo russianoracle/claude-code-actions

# Re-set a secret
echo -n "new-value" | gh secret set SECRET_NAME \
  --repo russianoracle/claude-code-actions --body -
```

### Workflow Not Triggering

```bash
# Check workflow status
gh workflow list

# View recent runs (including failures)
gh run list --limit 20

# View specific run logs
gh run view <run-id> --log
```

### Test Issue No Response

```bash
# Check workflow runs
gh run list --workflow=unified-ai-pipeline.yml --limit 5

# View logs of latest run
gh run view --log

# Common issues:
# - ANTHROPIC_API_KEY not set
# - Workflow not enabled
# - Bot detection filtered the trigger
```

## 📞 Help & Documentation

- **Full guide**: `CLAUDE.md`
- **Quick start**: `README.md`
- **Setup instructions**: `SETUP.md`
- **Automation ideas**: `.github/AUTOMATION_OPPORTUNITIES.md`
- **Workflow config**: `.github/workflow-config.yml`

## 🎉 Post-Setup

After all tasks complete, you can:

1. **Use automation daily**:
   - Create Linear issue → set "In Progress" → auto-implements
   - Comment `@claude implement` on GitHub issue
   - Add label `claude-implement` to issue
   - Request code review with `needs-ai-review` label

2. **Monitor workflows**:
   ```bash
   gh run watch  # Live monitoring
   gh run list --limit 10  # Recent runs
   ```

3. **Customize as needed**:
   - Edit workflows in `.github/workflows/`
   - Update prompts in `.github/system-prompts/`
   - Modify config in `.github/workflow-config.yml`
   - Add MCP servers in `.github/mcp-servers.json`

---

**Current Status**: ⚠️ Setup 80% complete - add missing secrets to finish

**Time to complete**: 5-10 minutes

**Last updated**: 2026-02-13
