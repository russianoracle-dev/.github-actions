#!/bin/bash
# Quick setup for claude-code-actions repository

set -e

REPO="russianoracle/claude-code-actions"

echo "🚀 Quick Setup: claude-code-actions"
echo "===================================="
echo ""

# Step 1: Verify repository
echo "📦 Step 1: Verify repository"
if ! gh repo view "$REPO" >/dev/null 2>&1; then
  echo "❌ Repository not found: $REPO"
  echo "   Run: gh repo create claude-code-actions --private"
  exit 1
fi
echo "✅ Repository exists: $REPO"
echo ""

# Step 2: Check secrets
echo "🔐 Step 2: Check secrets"
SECRETS_COUNT=$(gh secret list --repo "$REPO" 2>/dev/null | wc -l)
echo "   Found $SECRETS_COUNT secrets configured"

REQUIRED_SECRETS=(
  "ANTHROPIC_API_KEY"
  "ANTHROPIC_BASE_URL"
  "LINEAR_API_KEY"
  "GEMINI_API_KEY"
  "GEMINI_PROXY_ENDPOINT"
  "PROD_REPO_URL"
  "PROD_DEPLOY_KEY"
)

MISSING_SECRETS=()
for secret in "${REQUIRED_SECRETS[@]}"; do
  if ! gh secret list --repo "$REPO" 2>/dev/null | grep -q "^$secret"; then
    MISSING_SECRETS+=("$secret")
  fi
done

if [ ${#MISSING_SECRETS[@]} -gt 0 ]; then
  echo "⚠️  Missing secrets:"
  for secret in "${MISSING_SECRETS[@]}"; do
    echo "     - $secret"
  done
  echo ""
  echo "   Run: ./scripts/setup-secrets.sh"
  echo "   Or visit: https://github.com/$REPO/settings/secrets/actions"
else
  echo "✅ All required secrets are configured"
fi
echo ""

# Step 3: Check workflows
echo "⚙️  Step 3: Check workflows"
WORKFLOWS=$(gh workflow list --repo "$REPO" 2>/dev/null || echo "")
if [ -z "$WORKFLOWS" ]; then
  echo "❌ No workflows found"
  echo "   Push .github/workflows/ to repository"
  exit 1
fi

WORKFLOW_COUNT=$(echo "$WORKFLOWS" | wc -l)
echo "   Found $WORKFLOW_COUNT workflows"

# Check if any are disabled
DISABLED=$(echo "$WORKFLOWS" | grep -i "disabled" || true)
if [ -n "$DISABLED" ]; then
  echo "⚠️  Some workflows are disabled:"
  echo "$DISABLED" | head -3
  echo ""
  echo "   Enable with: gh workflow enable <workflow-name>"
else
  echo "✅ All workflows are enabled"
fi
echo ""

# Step 4: Test integration
echo "🧪 Step 4: Test integration (optional)"
echo "   Create test issue to verify automation:"
echo ""
echo "   gh issue create \\"
echo "     --repo $REPO \\"
echo "     --title '[TEST] Verify automation' \\"
echo "     --body 'Test issue for automation verification. @claude please respond' \\"
echo "     --label test"
echo ""

# Step 5: Summary
echo "📋 Setup Summary"
echo "================"
echo ""
echo "Repository: ✅ $REPO"
echo "Secrets:    $([ ${#MISSING_SECRETS[@]} -eq 0 ] && echo "✅" || echo "⚠️ ") $SECRETS_COUNT configured, ${#MISSING_SECRETS[@]} missing"
echo "Workflows:  ✅ $WORKFLOW_COUNT found"
echo ""

if [ ${#MISSING_SECRETS[@]} -eq 0 ]; then
  echo "🎉 Setup complete! Repository is ready for automation."
  echo ""
  echo "Next steps:"
  echo "  1. Create Linear issue and set status to 'In Progress'"
  echo "  2. Or add label 'claude-implement' to GitHub issue"
  echo "  3. Or comment '@claude implement' on issue"
  echo ""
  echo "Monitor runs:"
  echo "  gh run list --repo $REPO --limit 10"
else
  echo "⚠️  Setup incomplete. Configure missing secrets:"
  echo "  ./scripts/setup-secrets.sh"
  echo ""
fi
