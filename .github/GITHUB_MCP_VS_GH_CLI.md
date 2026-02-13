# GitHub MCP vs GitHub CLI: Детальное сравнение

## 🎯 Цель: Заменить gh CLI на GitHub MCP в workflow

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📊 Polnoe sravnenie vozmozhnostey

### GitHub MCP Server (@modelcontextprotocol/server-github)

**Тип:** MCP Server (stdio)
**Установка:** npx -y @modelcontextprotocol/server-github
**Документация:** https://github.com/modelcontextprotocol/servers

---

## 🔵 GitHub MCP: Polny spisok toolov

### 1. Repository Operations (github_repository)

```python
# Чтение файлов (ОСНОВНАЯ ФУНКЦИЯ)
github_repository.read_file(
    owner="russianoracle",
    repo="semantic-search-mcp",
    path="README.md",
    ref="main"  # branch, tag, or commit SHA
)
# Возвращает: { content: string, encoding: "utf-8" }

# Чтение файла из другой ветки (БЕЗ CHECKOUT!)
github_repository.read_file(
    owner="...",
    repo="...",
    path="pyproject.toml",
    ref="refs/heads/feature/new-feature"  # 直接读取其他分支
)
# ВАЖНО: Не требует git checkout!

# Создание/обновление файлов
github_repository.create_or_update_file(
    owner="...",
    repo="...",
    path="new_file.py",
    content="file content",
    message="feat: add new file",
    branch="feature-branch"
)

# Удаление файлов
github_repository.delete_file(
    owner="...",
    repo="...",
    path="old_file.py",
    message="remove deprecated file",
    branch="main"
)

# Получение metadata репозитория
github_repository.get(owner="...", repo="...")
# Возвращает: { name, description, default_branch, etc }

# Создание repository
github_repository.create(
    name="new-repo",
    description="...",
    visibility="public"
)

# Управление branch и refs
github_repository.create_ref(
    owner="...",
    repo="...",
    ref="refs/heads/feature-branch",
    sha="commit_sha"
)

github_repository.delete_ref(
    owner="...",
    repo="...",
    ref="refs/heads/feature-branch"
)
```

---

### 2. Issues Operations (github_issue)

```python
# Создание issue
github_issue.create(
    owner="russianoracle",
    repo="semantic-search-mcp",
    title="Bug: entry point import fails",
    body="## Problem\n\nEntry point...",
    labels=["bug", "high-priority"],
    assignees=["russianoracle"]
)
# Возвращает: { number, html_url, ... }

# Чтение issue
github_issue.get(
    owner="...",
    repo="...",
    issue_number=150
)
# Возвращает: { title, body, state, labels, ... }

# Обновление issue
github_issue.update(
    owner="...",
    repo="...",
    issue_number=150,
    state="closed",
    title="Updated title",
    body="New description",
    labels=["bug", "fixed"]
)

# Добавление комментария
github_issue.create_comment(
    owner="...",
    repo="...",
    issue_number=150,
    body="Fixed in version 1.2.3"
)
# Возвращает: { id, html_url, ... }

# Список issues
github_issue.list(
    owner="...",
    repo="...",
    state="open",
    labels=["bug"],
    creator="russianoracle"
)
# Возвращает: [{ number, title, ... }, ...]

# Закрытие issue
github_issue.close(
    owner="...",
    repo="...",
    issue_number=150,
    comment="Fixed and tested"
)

# Переоткрытие
github_issue.reopen(
    owner="...",
    repo="...",
    issue_number=150
)
```

---

### 3. Pull Request Operations (github_pr)

```python
# Создание PR
github_pr.create(
    owner="...",
    repo="...",
    title="feat: add new feature",
    body="## Changes\n\n...",
    head="feature-branch",
    base="main",
    draft=False
)
# Возвращает: { number, html_url, ... }

# Чтение PR
github_pr.get(
    owner="...",
    repo="...",
    pull_number=123
)
# Возвращает: { title, body, state, head, base, ... }

# Обновление PR
github_pr.update(
    owner="...",
    repo="...",
    pull_number=123,
    title="Updated title",
    body="New description",
    state="closed"
)

# Список PR
github_pr.list(
    owner="...",
    repo="...",
    state="open",
    head="feature-branch",
    base="main"
)
# Возвращает: [{ number, title, ... }, ...]

# Получение файлов в PR
github_pr.list_files(
    owner="...",
    repo="...",
    pull_number=123
)
# Возвращает: [{ filename, status, additions, deletions }, ...]

# Получение diff PR
github_pr.get_diff(
    owner="...",
    repo="...",
    pull_number=123
)
# Возвращает: строка с diff (в унифицированном формате)

# Добавление комментария
github_pr.create_comment(
    owner="...",
    repo="...",
    pull_number=123,
    body="LGTM!"
)

# Создание review
github_pr.create_review(
    owner="...",
    repo="...",
    pull_number=123,
    body="Great work!",
    event="APPROVE"  # или "COMMENT", "REQUEST_CHANGES", etc
)

# Слияние PR
github_pr.merge(
    owner="...",
    repo="...",
    pull_number=123,
    merge_method="merge"  # или "squash", "rebase"
)

# Закрытие PR
github_pr.close(
    owner="...",
    repo="...",
    pull_number=123,
    comment="Superseded by #456"
)
```

---

### 4. Search Operations (github_search)

```python
# Поиск code
github_search.code(
    q="language:python semantix_rag",
    owner="russianoracle",
    repo="semantic-search-mcp"
)
# Возвращает: [{ path, html_url, ... }, ...]

# Поиск issues
github_search.issues(
    q="is:open label:bug",
    owner="...",
    repo="..."
)
# Возвращает: [{ number, title, ... }, ...]

# Поиск PRs
github_search.pull_requests(
    q="is:merged author:russianoracle",
    owner="...",
    repo="..."
)
# Возвращает: [{ number, title, ... }, ...]
```

---

## 🟢 GitHub CLI (gh): Polny spisok komand

### Repository Operations

```bash
# Чтение файлов
gh api /repos/russianoracle/semantic-search-mcp/contents/README.md

# Чтение файла из другой ветки
gh api /repos/.../contents/pyproject.toml?ref=feature-branch

# Создание файла
gh api -X PUT /repos/.../contents/new_file.py \
  -f message="feat: add file" \
  -f content="base64encoded"

# Получение metadata
gh repo view russianoracle/semantic-search-mcp --json name,description

# Создание репозитория
gh repo create new-repo --public --description "..."

# Branch операции
gh api -X POST /repos/.../git/refs \
  -f ref='refs/heads/feature' \
  -f sha='abc123'

gh api -X DELETE /repos/.../git/refs/refs/heads/feature
```

---

### Issue Operations

```bash
# Создание issue
gh issue create \
  --repo russianoracle/semantic-search-mcp \
  --title "Bug: entry point import fails" \
  --body "## Problem\n..." \
  --label "bug,high-priority"

# Чтение issue
gh issue view 150 \
  --repo russianoracle/semantic-search-mcp \
  --json title,body,state,labels

# Обновление issue
gh issue edit 150 \
  --repo russianoracle/semantic-search-mcp \
  --title "Updated title" \
  --state closed \
  --add-label "fixed"

# Комментарий
gh issue comment 150 \
  --repo russianoracle/semantic-search-mcp \
  --body "Fixed!"

# Список issues
gh issue list \
  --repo russianoracle/semantic-search-mcp \
  --state open \
  --label bug \
  --json number,title

# Закрытие
gh issue close 150 --repo ...
gh issue reopen 150 --repo ...
```

---

### Pull Request Operations

```bash
# Создание PR
gh pr create \
  --repo russianoracle/semantic-search-mcp \
  --title "feat: add new feature" \
  --body "## Changes\n..." \
  --base main \
  --head feature-branch

# Чтение PR
gh pr view 123 \
  --repo russianoracle/semantic-search-mcp \
  --json title,body,state,head,base

# Обновление PR
gh pr edit 123 \
  --repo ... \
  --title "New title"

# Список PR
gh pr list \
  --repo ... \
  --state open \
  --json number,title

# Файлы в PR
gh pr diff 123 --name-only

# Diff PR
gh pr diff 123

# Комментарий
gh pr comment 123 --body "LGTM!"

# Review
gh pr review 123 \
  --body "Great work!" \
  --approve

# Слияние
gh pr merge 123 --merge

# Закрытие
gh pr close 123 --comment "Superseded"
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## ⚔️ Sravnenie po kategoriyam

### ЧТЕНИЕ ФАЙЛОВ

| Операция                            | GitHub MCP                              | gh CLI                                         |
|--------------------------------------|-----------------------------------------|------------------------------------------------|
| Читать файл                         | `read_file(path, ref)`                   | `gh api /repos/.../contents/...`           |
| Читать из другой ветки              | `read_file(path, ref="feature/x")`       | `gh api /repos/.../contents/...?ref=...`    |
| Batch чтение                         | N/A (по одному файлу)                    | Можно циклом, но громоздко                |
| **Победитель**                      | **GitHub MCP** (проще API)              | -                                             |

---

### СОЗДАНИЕ ISSUE/PR

| Операция                            | GitHub MCP                              | gh CLI                                         |
|--------------------------------------|-----------------------------------------|------------------------------------------------|
| Создать issue                        | `create(title, body, labels)`            | `gh issue create --title ... --body ...`     |
| Создать PR                           | `create(title, body, head, base)`        | `gh pr create --title ... --body ...`        |
| **Победитель**                      | **Ничья** (равные возможности)          | -                                             |

---

### СПИСКИ И ПОИСК

| Операция                            | GitHub MCP                              | gh CLI                                         |
|--------------------------------------|-----------------------------------------|------------------------------------------------|
| Список issues                        | `list(state="open")`                     | `gh issue list --state open`                 |
| Список PR                            | `list(state="open")`                     | `gh pr list --state open`                    |
| Поиск code                           | `search.code(q="...")`                    | Нужен `gh search code` (ограничен)          |
| Фильтрация                           | Встроенные параметры                      | jq парсинг JSON                             |
| **Победитель**                      | **GitHub MCP** (структурированные данные) | -                                             |

---

### ОБНОВЛЕНИЕ/ИЗМЕНЕНИЕ

| Операция                            | GitHub MCP                              | gh CLI                                         |
|--------------------------------------|-----------------------------------------|------------------------------------------------|
| Изменить title/body                  | `update(issue, title=...)`                | `gh issue edit --title ...`                   |
| Добавить комментарий                 | `create_comment(...)`                     | `gh issue comment --body ...`                |
| Изменить labels                       | `update(..., labels=[...])`               | `gh issue edit --add-label ...`              |
| Закрытие/reopen                     | `close(...)` / `reopen(...)`              | `gh issue close` / `gh issue reopen`         |
| **Победитель**                      | **Ничья** (равные)                         | -                                             |

---

### ERROR HANDLING

| Аспект                               | GitHub MCP                              | gh CLI                                         |
|--------------------------------------|-----------------------------------------|------------------------------------------------|
| Структурированные ошибки              | Exceptions + error messages               | Exit codes + stdout/stderr                    |
| Retry логика                         | Встроено (retryAttempts в конфиге)       | Нужно реализовывать самому                   |
| Timeout                              | Конфигурируется                           | Фиксированный (gh --timeout)                 |
| **Победитель**                      | **GitHub MCP** (лучше)                   | -                                             |

---

### ИНТЕГРАЦИЯ С WORKFLOW

| Аспект                               | GitHub MCP                              | gh CLI                                         |
|--------------------------------------|-----------------------------------------|------------------------------------------------|
| Вызов из Python/Claude                | Нативный: `github_repo.read_file()`     | Через Bash: `Bash(gh issue create ...)`     |
| Передача параметров                   | Python параметры                          | Bash переменные + quoting                   |
| Парсинг результатов                   | Python объекты (dict, list)               | jq парсинг JSON                             |
| Composition операций                  | Легко в Python                            | Сложно в Bash                               |
| **Победитель**                      | **GitHub MCP** (намного лучше)           | -                                             |

---

### УДОБСТВО В КОДЕ

**GitHub MCP:**
```python
# Чистый Python код
prs = github_pr.list(state="open")
bug_prs = [pr for pr in prs if "bug" in pr.title.lower()]

for pr in bug_prs:
    github_pr.create_comment(pr.number, "This is a bug")
```

**gh CLI:**
```bash
# Bash + jq
prs=$(gh pr list --state open --json number,title)
bug_prs=$(echo "$prs" | jq -r '.[] | select(.title | test("bug"; "i")) | .number')

for pr_num in $bug_prs; do
  gh pr comment "$pr_num" --body "This is a bug"
done
```

**Победитель:** GitHub MCP (на порядок чище и понятнее)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📊 Итоговая таблица

| Категория                     | GitHub MCP | gh CLI | Победитель   |
|-------------------------------|-----------|--------|-------------|
| **Reading files**            | 9/10      | 7/10    | MCP ✅       |
| **Creating issues/PRs**     | 9/10      | 9/10    | Ничья       |
| **Listing/filtering**        | 9/10      | 6/10    | MCP ✅       |
| **Updating**                 | 9/10      | 8/10    | MCP (слегко) |
| **Error handling**           | 10/10     | 6/10    | MCP ✅       |
| **Python/Claude integration**| 10/10     | 5/10    | MCP ✅       |
| **Code clarity**             | 10/10     | 5/10    | MCP ✅       |
| **Learning curve**          | 7/10      | 9/10    | CLI ✅       |
| **Debugging**                | 8/10      | 9/10    | CLI ✅       |

**Общий счёт:** GitHub MCP 85/100 vs gh CLI 70/100

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🎯 Когда какой лучше

### Используй GitHub MCP когда:

✅ Нужно читать файлы из разных веток
✅ Работа в Python/Claude (нативная интеграция)
✅ Сложная логика с условиями/циклами
✅ Нужны структурированные данные
✅ Требуется error handling
✅ Batch операции над issues/PRs

### Используй gh CLI когда:

✅ Быстрые one-off команды в терминале
✅ Скрипты на Bash
✅ Уже знаешь gh команды
✅ Отладка (можно скопировать и запустить)
✅ Простые операции без сложной логики

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 💡 Вывод

**Для CI/CD workflow (Claude/actions):**
- GitHub MCP **ЗНАЧИТЕЛЬНО лучше** для интеграции
- gh CLI остаётся для ручного использования

**Для разработки:**
- gh CLI удобнее для быстрых команд
- GitHub MCP лучше для скриптов и автоматизации

**Рекомендация:** Заменить gh CLI на GitHub MCP в workflow, оставить gh CLI для локальной работы.

