#!/usr/bin/env bash
# Copy secrets from semantic-search-mcp .env file to claude-code-actions repository
# Compatible with bash 3.2+ (macOS default)

set -e

TARGET_REPO="russianoracle/claude-code-actions"
SOURCE_ENV="/Users/artemgusarov/Downloads/PROJECTS/semantic-search-mcp/.env"

echo "🔐 Copying secrets from .env to GitHub repository"
echo "=================================================="
echo ""

# Check if .env file exists
if [ ! -f "$SOURCE_ENV" ]; then
  echo "❌ .env file not found: $SOURCE_ENV"
  echo ""
  echo "Alternative methods:"
  echo "  1. Run: ./scripts/setup-secrets.sh (manual input)"
  echo "  2. Set secrets via GitHub UI:"
  echo "     https://github.com/$TARGET_REPO/settings/secrets/actions"
  exit 1
fi

echo "✅ Found .env file: $SOURCE_ENV"
echo ""

# Required secrets
REQUIRED_SECRETS=(
  "ANTHROPIC_API_KEY"
  "ANTHROPIC_BASE_URL"
  "LINEAR_API_KEY"
  "GEMINI_API_KEY"
  "GEMINI_PROXY_ENDPOINT"
  "PROD_REPO_URL"
  "PROD_DEPLOY_KEY"
)

# Function to get value from .env file
get_env_value() {
  local key=$1
  local value=""

  # Read .env line by line
  while IFS='=' read -r env_key env_value; do
    # Skip comments and empty lines
    [[ "$env_key" =~ ^#.*$ ]] && continue
    [[ -z "$env_key" ]] && continue

    # Trim whitespace
    env_key=$(echo "$env_key" | xargs)
    env_value=$(echo "$env_value" | xargs)

    # Remove quotes from value
    env_value=$(echo "$env_value" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")

    # Match key
    if [ "$env_key" = "$key" ]; then
      value="$env_value"
      break
    fi
  done < "$SOURCE_ENV"

  echo "$value"
}

# Function to set secret
set_secret() {
  local secret_name=$1
  local value=$(get_env_value "$secret_name")

  if [ -z "$value" ]; then
    echo "⚠️  $secret_name - not found in .env, skipping"
    return 1
  fi

  # Check if already exists
  if gh secret list --repo "$TARGET_REPO" 2>/dev/null | grep -q "^$secret_name"; then
    echo "ℹ️  $secret_name - already exists, updating..."
  else
    echo "📝 $secret_name - setting..."
  fi

  # Set secret (value via stdin for security)
  if echo -n "$value" | gh secret set "$secret_name" --repo "$TARGET_REPO" --body - 2>/dev/null; then
    echo "✅ $secret_name - set successfully"
    return 0
  else
    echo "❌ $secret_name - failed to set"
    return 1
  fi
}

echo "🔄 Setting secrets..."
echo ""

# Set all secrets
SUCCESS_COUNT=0
FAILED_COUNT=0

for secret_name in "${REQUIRED_SECRETS[@]}"; do
  if set_secret "$secret_name"; then
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  else
    FAILED_COUNT=$((FAILED_COUNT + 1))
  fi
done

echo ""
echo "---"
echo "📊 Summary:"
echo "   ✅ Success: $SUCCESS_COUNT"
echo "   ❌ Failed:  $FAILED_COUNT"
echo ""

# Verify
echo "📋 Verifying secrets in repository..."
gh secret list --repo "$TARGET_REPO"
echo ""

SECRETS_COUNT=$(gh secret list --repo "$TARGET_REPO" 2>/dev/null | wc -l | xargs)

if [ "$SECRETS_COUNT" -ge 7 ]; then
  echo "🎉 All required secrets configured successfully!"
  echo ""
  echo "Next steps:"
  echo "  1. Verify workflows:"
  echo "     gh workflow list --repo $TARGET_REPO"
  echo ""
  echo "  2. Run quick setup check:"
  echo "     ./scripts/quick-setup.sh"
  echo ""
  echo "  3. Create test issue:"
  echo "     gh issue create --repo $TARGET_REPO \\"
  echo "       --title '[TEST] Verify automation' \\"
  echo "       --body '@claude please respond' \\"
  echo "       --label test"
else
  echo "⚠️  Some secrets are missing (found $SECRETS_COUNT, need 7+)"
  echo ""
  echo "Manual setup:"
  echo "  https://github.com/$TARGET_REPO/settings/secrets/actions"
fi
