# Migration Plan: gh CLI → GitHub MCP

## 🎯 Что заменяем в unified-ai-pipeline.yml

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📍 Текущие использования gh CLI

### 1. Idempotency check (строки ~368-413)

**СЕЙЧАС (gh CLI + jq):**
```yaml
# Получить все открытые PR
ALL_PRS=$(gh pr list --repo ${{ github.repository }} --state open --json number,title,body)

# Проверка 1: PR с Linear ID в title
EXISTING_PR=$(echo "$ALL_PRS" | jq -r ".[] |
  select(.title | test(\"\\[$LINEAR_ID\\]\"; \"i\")) | .number" | head -1
)

# Проверка 2: Если не найдено, другой формат
if [ -z "$EXISTING_PR" ]; then
  EXISTING_PR=$(echo "$ALL_PRS" | jq -r ".[] |
    select(.title | test(\"\\($LINEAR_ID\\)\"; \"i\")) | .number" | head -1
  )
fi

# Проверка 3: Plain string
if [ -z "$EXISTING_PR" ]; then
  EXISTING_PR=$(echo "$ALL_PRS" | jq -r ".[] |
    select(.title | test(\"$LINEAR_ID\"; \"i\")) | .number" | head -1
  )
fi

# Проверка 4: PR body mentions issue
if [ -z "$EXISTING_PR" ] && [ -n "$ISSUE_NUM" ]; then
  EXISTING_PR=$(echo "$ALL_PRS" | jq -r ".[] |
    select(.body | test(\"(closes|fixes|resolves).*#$ISSUE_NUM\"; \"i\")) | .number"
)

echo "   Check closes #issue in body: ${EXISTING_PR:-none}"
```

**БУДЕТ (GitHub MCP):**
```yaml
# В Claude action prompt:
"""
# Check for existing PR with this Linear ID
prs = github_pr.list(
    owner="russianoracle",
    repo="semantic-search-mcp",
    state="open"
)

# Check for Linear ID in title
for pr in prs:
    if f"[{LINEAR_ID}]" in pr.title or f"({LINEAR_ID})" in pr.title:
        existing_pr = pr.number
        break

# Check for issue reference
if not existing_pr and ISSUE_NUM:
    for pr in prs:
        if f"fixes #{ISSUE_NUM}" in pr.body or f"closes #{ISSUE_NUM}" in pr.body:
            existing_pr = pr.number
            break
"""
```

**Выигрыш:**
- ✅ Меньше кода (10 строк → 10 строк но понятнее)
- ✅ Нет jq парсинга
- ✅ Структурированные данные
- ✅ Легче debugging

---

### 2. Notify skipped (строки ~494-509)

**СЕЙЧАС (gh CLI):**
```yaml
if [ -n "$ISSUE_NUM" ]; then
  gh issue comment "$ISSUE_NUM" --repo ${{ github.repository }} \
    --body "ℹ️ **Skipped duplicate action**..."
fi
```

**БУДЕТ (GitHub MCP):**
```yaml
# В Claude action prompt:
"""
if ISSUE_NUM:
    github_issue.create_comment(
        owner="russianoracle",
        repo="semantic-search-mcp",
        issue_number=ISSUE_NUM,
        body="ℹ️ **Skipped duplicate action**..."
    )
"""
```

**Выигрыш:**
- ✅ Native Python вместо Bash
- ✅ Структурированный ответ
- ✅ Легче error handling

---

### 3. Release version (строки ~517-529)

**СЕЙЧАС (git):**
```yaml
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
LATEST_VERSION=${LATEST_TAG#v}
IFS='.' read -r MAJOR MINOR PATCH <<< "$LATEST_VERSION"
NEW_PATCH=$((PATCH + 1))
NEW_VERSION="v${MAJOR}.${MINOR}.${NEW_PATCH}"
```

**БУДЕТ (остаётся git):**
Это git операция, не GitHub API. Оставляется как есть.

---

### 4. Linear notifications (строки ~621-649)

**СЕЙЧАС (curl + jq):**
```yaml
ISSUE_DATA=$(curl -s -X POST https://api.linear.app/graphql \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"{ issue(id: \\\"$LINEAR_ID\\\") { id } }\"}")

ISSUE_ID=$(echo "$ISSUE_DATA" | jq -r '.data.issue.id // empty')

if [ -n "$ISSUE_ID" ]; then
  curl -s -X POST https://api.linear.app/graphql \
    -H "Authorization: $LINEAR_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"query\": \"mutation { commentCreate(...) }\"}"
fi
```

**БУДЕТ (Linear MCP - уже используется!):**
```yaml
# Linear MCP server уже настроен
# Оставляется как есть
```

**Уже хорошо!** ✅

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📊 Summary замен

| Место в workflow | Сейчас              | Станет              | Выигрыш                  |
|------------------|---------------------|----------------------|--------------------------|
| Idempotency check | gh pr list + jq     | github_pr.list      | Меньше bash, понятнее   |
| Skipped comment  | gh issue comment    | github_issue.create_comment | Native Python      |
| Git operations   | git (остаётся)     | git (остаётся)      | Без изменений           |
| Linear sync       | curl + jq (Linear MCP) | Linear MCP           | Уже хорошо!            |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🎯 Результат

**Заменяем gh CLI на GitHub MCP для:**
- ✅ Список PR
- ✅ Поиск PR по Linear ID
- ✅ Комментарии в issues
- ✅ Создание issues/PR (если нужно)

**Оставляем:**
- ✅ Git операции (commit/push/etc)
- ✅ Linear MCP (уже отлично работает)

**Изменений в коде:** ~50-80 строк упрощаются

