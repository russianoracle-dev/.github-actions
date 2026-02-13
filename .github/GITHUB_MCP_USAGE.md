# GitHub MCP Usage Guide for Claude

## 🎯 Золотое правило

**В workflow используй GitHub MCP для GitHub операций**

**gh CLI оставь ТОЛЬКО для чтения файлов без клонирования репозитория**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## ✅ Используй GitHub MCP для

### 1. Списки PR и Issues

```python
# Вместо gh pr list + jq:
prs = github_pr.list(
    owner="russianoracle",
    repo="semantic-search-mcp",
    state="open"
)

# Вместо gh issue list:
issues = github_issue.list(
    state="open",
    labels=["bug"]
)
```

### 2. Поиск PR по Linear ID

```python
# Найти PR с Linear ID в названии
prs = github_pr.list(state="open")

for pr in prs:
    if "[SMNTX-93]" in pr.title:
        existing_pr = pr.number
        break

# Или с готовыми параметрами
prs_filtered = [p for p in prs if "SMNTX-93" in p.title]
```

### 3. Комментарии в Issues/PRs

```python
# Создать комментарий
github_issue.create_comment(
    owner="...",
    repo="...",
    issue_number=150,
    body="Update: Fix verified"
)

# Комментарий в PR
github_pr.create_comment(
    pull_number=123,
    body="LGTM!"
)
```

### 4. Создание Issues

```python
github_issue.create(
    owner="...",
    repo="...",
    title="Bug: entry point fails",
    body="## Problem\n\n...",
    labels=["bug", "high-priority"],
    assignees=["russianoracle"]
)
```

### 5. Создание PR

```python
github_pr.create(
    owner="...",
    repo="...",
    title="feat: add new feature",
    body="## Changes\n\n...",
    head="feature-branch",
    base="main"
)
```

### 6. Обновление Issues/PRs

```python
# Закрыть issue
github_issue.close(
    issue_number=150,
    comment="Fixed and tested"
)

# Добавить labels
github_issue.update(
    issue_number=150,
    labels=["bug", "verified"]
)

# Мержить PR
github_pr.merge(
    pull_number=123,
    merge_method="merge"
)
```

### 7. Проверка существования PR

```python
# Idempotency check
prs = github_pr.list(state="open")

# Проверка по Linear ID
for pr in prs:
    if f"[SMNTX-93]" in pr.title:
        existing = pr.number
        break

# Проверка по issue reference
if not existing and ISSUE_NUM:
    for pr in prs:
        if f"closes #{ISSUE_NUM}" in pr.body:
            existing = pr.number
            break
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🚫 НЕ ИСПОЛЬЗУЙ gh CLI в workflow

**В Claude действиях (prompts):**
- ❌ gh pr list
- ❌ gh issue create
- ❌ gh issue comment
- ❌ gh pr create
- ❌ gh api /repos/...

**ВСЕ это через GitHub MCP!**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📌 Когда использовать gh CLI (outside workflow)

**gh CLI оставлен для:**
- ✅ Быстрое чтение файла без clone (handy для локальной работы)
- ✅ Скрипты вне GitHub Actions
- ✅ Ручные операции в терминале
- ✅ Отладка (можно скопировать команду)

**Пример:**
```bash
# Локально прочитать файл БЕЗ git clone
gh api /repos/russianoracle/semantic-search-mcp/contents/README.md

# Или через raw.githubusercontent.com
curl https://raw.githubusercontent.com/russianoracle/semantic-search-mcp/main/README.md
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 💡 Примеры замены

### СЕЙЧАС (gh CLI + jq):
```bash
ALL_PRS=$(gh pr list --repo $REPO --state open --json number,title,body)
EXISTING_PR=$(echo "$ALL_PRS" | jq -r '.[] |
  select(.title | test("\\[SMNTX-93\\]"; "i")) | .number')

if [ -n "$EXISTING_PR" ]; then
  gh issue comment "$ISSUE_NUM" --body "Skip..."
fi
```

### БУДЕТ (GitHub MCP + Python):
```python
# Claude action prompt:
"""
Use GitHub MCP tools to check for existing PRs.

prs = github_pr.list(
    owner="russianoracle",
    repo="semantic-search-mcp",
    state="open"
)

# Check for Linear ID in title
existing = None
for pr in prs:
    if "[SMNTX-93]" in pr.title:
        existing = pr.number
        break

# If found, notify and skip
if existing:
    github_issue.create_comment(
        issue_number=ISSUE_NUM,
        body="ℹ️ Skipped: PR already exists"
    )
"""
```

**Преимущества:**
- ✅ Меньше bash кода
- ✅ Нет jq парсинга
- ✅ Структурированные данные
- ✅ Легче debugging

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🔗 Quick Reference

| Операция              | GitHub MCP                             |
|----------------------|-----------------------------------------|
| Список PR             | `github_pr.list(state="open")`         |
| Найти PR по pattern  | `[p for p in prs if "keyword" in p.title]` |
| Комментарий            | `github_issue.create_comment(issue_number, body)` |
| Создать issue          | `github_issue.create(title, body, labels)` |
| Создать PR             | `github_pr.create(title, body, head, base)` |
| Закрыть issue          | `github_issue.close(issue_number)` |
| Мержить PR             | `github_pr.merge(pull_number)` |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## ✅ Checklist

Перед коммитом проверь:

- [ ] GitHub MCP добавлен в .github/mcp-servers.json
- [ ] GITHUB_TOKEN передаётся в workflow
- [ ] Claude prompts используют GitHub MCP (не gh CLI)
- [ ] gh CLI оставлен только для чтения файлов без clone
- [ ] Все gh pr/gh issue вызовы заменены на GitHub MCP
- [ ] Idempotency check использует github_pr.list
- [ ] Комментарии используют github_issue.create_comment

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🎯 Goal

**ОДИН инструмент для GitHub операций в workflow = GitHub MCP**

**gh CLI для чтения файлов вне GitHub Actions**

Простота = нет путаницы! 🎯
