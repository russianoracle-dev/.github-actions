#!/bin/bash
# Helper script to copy secrets from semantic-search-mcp to claude-code-actions

set -e

SOURCE_REPO="russianoracle/semantic-search-mcp"
TARGET_REPO="russianoracle/claude-code-actions"

echo "🔐 Setting up secrets for $TARGET_REPO"
echo "---"

# Required secrets for claude-code-actions
REQUIRED_SECRETS=(
  "ANTHROPIC_API_KEY"
  "ANTHROPIC_BASE_URL"
  "LINEAR_API_KEY"
  "GEMINI_API_KEY"
  "GEMINI_PROXY_ENDPOINT"
  "PROD_REPO_URL"
  "PROD_DEPLOY_KEY"
)

echo "📋 Required secrets:"
for secret in "${REQUIRED_SECRETS[@]}"; do
  echo "  - $secret"
done
echo ""

# Check if source repo has secrets
echo "🔍 Checking secrets in source repo ($SOURCE_REPO)..."
SOURCE_SECRETS=$(gh secret list --repo "$SOURCE_REPO" 2>/dev/null || echo "")

if [ -z "$SOURCE_SECRETS" ]; then
  echo "❌ Cannot access secrets in $SOURCE_REPO"
  exit 1
fi

echo "✅ Found $(echo "$SOURCE_SECRETS" | wc -l) secrets in source repo"
echo ""

# Function to copy secret
copy_secret() {
  local secret_name=$1

  echo "📝 Setting up: $secret_name"

  # Check if secret exists in source
  if ! echo "$SOURCE_SECRETS" | grep -q "^$secret_name"; then
    echo "  ⚠️  Not found in source repo - skipping"
    return
  fi

  # Check if already exists in target
  if gh secret list --repo "$TARGET_REPO" 2>/dev/null | grep -q "^$secret_name"; then
    echo "  ℹ️  Already exists in target repo - skipping"
    return
  fi

  # Note: gh CLI doesn't allow reading secret values for security
  # User must manually copy via GitHub UI or provide value

  echo "  ⚠️  Secret exists in source but cannot be read via CLI"
  echo "  📌 Please copy manually from:"
  echo "     https://github.com/$SOURCE_REPO/settings/secrets/actions"
  echo "  📌 To:"
  echo "     https://github.com/$TARGET_REPO/settings/secrets/actions"
  echo ""

  read -p "  Have you copied $secret_name manually? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "  ✅ Marked as done"
  else
    echo "  ⏭️  Skipped - remember to copy later!"
  fi
  echo ""
}

# Copy all required secrets
for secret in "${REQUIRED_SECRETS[@]}"; do
  copy_secret "$secret"
done

echo "---"
echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "  1. Verify all secrets are set:"
echo "     gh secret list --repo $TARGET_REPO"
echo ""
echo "  2. Test workflows:"
echo "     gh workflow list --repo $TARGET_REPO"
echo ""
echo "  3. Enable workflows (if disabled):"
echo "     gh workflow enable unified-ai-pipeline.yml --repo $TARGET_REPO"
