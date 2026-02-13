# 🚀 GitHub MCP: Дополнительные возможности автоматизации

## 🎯 Что можно ЕЩЁ автоматизировать в твоих pipeline'ах

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 1. 🧹 Автоматический cleanup старых веток

**Текущий workflow:** cleanup.yml (ручной trigger)

**Можно добавить:** Автоматическое удаление merged веток

```python
# После merge PR:
github_pr.get(pr_number=123)
# Если PR merged и старше 7 дней:
for branch in old_branches:
    if pr.merged_at and (now - pr.merged_at) > 7 days:
        # Удалить branch
        github_repository.delete_ref(
            owner="...",
            repo="...",
            ref=f"refs/heads/{branch['name']}"
        )

        # Оставить комментарий
        github_issue.create_comment(
            issue_number=pr.related_issue,
            body=f"Branch {branch} deleted (merged 7 days ago)"
        )
```

**Выгоды:**
- ✅ Репозиторий чистый
- ✅ Не накопливаются dead branches
- ✅ Автоматизация после merge

---

## 2. 📊 Dependency Tracker - автоматические updates

**Текущий workflow:** dependency-tracker.yml (только оповещения)

**Можно добавить:** Auto-update dependencies + auto-PR

```python
# GitHub MCP + Automated dependency management

# 1. Найти устаревшие зависимости
deps = github_search.code(
    q="language:python filename:requirements.txt deprecated:true",
    owner="russianoracle",
    repo="semantic-search-mcp"
)

# 2. Создать issue с деталями
for dep in deps:
    # Проверить есть ли обновление
    latest_version = check_pypi_version(dep.package_name)

    if dep.current_version < latest_version:
        # Создать issue
        github_issue.create(
            title=f"Update {dep.package_name} from {dep.current_version} to {latest_version}",
            body=f"""
## Package {dep.package_name}

Current: {dep.current_version}
Latest: {latest_version}

Found in: {dep.path}

Automated detection by dependency-tracker.
            """,
            labels=["dependencies", "auto-update"]
        )

        # Создать PR с обновлением (если testing нужен)
        # github_pr.create(...)

# 3. Отслеживать статус обновления
# Если issue открыт > 7 дней, добавить метку "stale"
# Если issue открыт > 30 дней, закрыть как "stale"
```

**Выгоды:**
- ✅ Автоматическое обнаружение устаревших deps
- ✅ Auto-update PRs (если настроено)
- � Не забывает обновлять зависимости

---

## 3. 📝 Release Notes - автоматическая генерация

**Текущий workflow:** release-notes.yml

**Можно улучшить:** Automatic release notes from commits + PRs

```python
# GitHub MCP для автоматических release notes

# 1. Получить все PRs с последнего релиза
prs = github_pr.list(
    owner="...",
    repo="...",
    state="closed",
    base="main",
    since="v1.2.3"  # последний тег
)

# 2. Категоризировать изменения
features = [p for p in prs if "feat" in p.title.lower()]
bugfixes = [p for p in prs if "fix" in p.title.lower()]
docs = [p for p in prs if "doc" in p.title.lower()]

# 3. Сгенерировать release notes
release_notes = f"""
# Release {new_version}

## 🚀 Features
{chr(10).join(f"- {p.title}" for p in features)}

## 🐛 Bug Fixes
{chr(10).join(f"- {p.title}" for p in bugfixes)}

## 📚 Documentation
{chr(10).join(f"- {p.title}" for p in docs)}

## Contributors
{', '.join(set(p.author for p in prs))}
"""

# 4. Создать GitHub Release
github_repository.create_release(
    owner="...",
    repo="...",
    tag_name=f"v{new_version}",
    name=f"Release {new_version}",
    body=release_notes
)

# 5. Опубликовать в других каналах (Linear, Discord и т.д.)
# через другие MCP инструменты
```

**Выгоды:**
- ✅ Автоматические release notes
- ✅ Не забывает ничего упомянуть
- ✅ Структурированный формат

---

## 4. 🔍 Code Review automation

**Текущий workflow:** claude-code-review.yml (on-demand)

**Можно добавить:** Auto-review on PR with статусом "Ready for Review"

```python
# GitHub MCP для автоматического code review

# 1. При добавлении метки "ready-for-review"

# 2. Скачать PR diff
pr_diff = github_pr.get_diff(pull_number=pr_number)

# 3. Анализировать diff (через AI или правила)
issues = analyze_code(pr_diff)

if issues:
    # Создать ревью с комментариями
    github_pr.create_review(
        owner="...",
        repo="...",
        pull_number=pr_number,
        body=issues,
        event="COMMENT"  # или REQUEST_CHANGES если критично
    )

    # Добавить метку "needs-changes"
    github_pr.update(
        pull_number=pr_number,
        labels=["needs-changes"]
    )
else:
    # Если всё ОК, approve
    github_pr.create_review(
        pull_number=pr_number,
        body="LGTM!",
        event="APPROVE"
    )

    # Добавить метку "approved"
    github_pr.update(
        pull_number=pr_number,
        labels=["approved"]
    )
```

**Выгоды:**
- ✅ Автоматическая проверка PR
- ✅ Быстрый feedback
- ✅ consistent code standards

---

## 5. 🔄 Improved Linear ↔ GitHub Sync

**Текущие workflow:** linear-sync.yml + pr-linear-sync.yml

**Можно улучшить:** Bi-directional sync с GitHub MCP

```python
# GitHub MCP для улучшенной синхронизации

# Linear → GitHub (уже есть через Linear MCP)
# Добавить GitHub → Linear через GitHub MCP:

# 1. При создании issue в GitHub:
issue = github_issue.get(issue_number=123)

# 2. Создать соответствующий Linear issue
linear_issue = linear.create_issue(
    title=issue.title,
    description=issue.body,
    labels=[issue.labels]
)

# 3. Сохранить связь GitHub issue ← → Linear issue
github_issue.update(
    issue_number=issue_number,
    body=f"Linked to Linear: {linear_issue.url}"
)

# 4. При создании PR в GitHub:
pr = github_pr.get(pull_number=123)

# 5. Найти связанный Linear issue
linear_id = extract_linear_id(pr.title)

# 6. Обновить Linear статус → "In Review"
linear.update_issue(
    linear_id=linear_id,
    status="in-review",
    github_pr_url=pr.html_url
)
```

**Выгоды:**
- ✅ Полная双向ная синхронизация
- � Никаких lost updates
- ✅ Consistent status across systems

---

## 6. 📈 Sprint Planning automation

**Текущий workflow:** sprint-planning.yml

**Можно добавить:** Auto-create sprint planning issues

```python
# GitHub MCP для автоматического планирования

# 1. Получить все открытые issues с меткой "backlog"
backlog = github_issue.list(
    state="open",
    labels=["backlog"]
)

# 2. Категоризировать по приоритету
high_priority = [i for i in backlog if "high" in i.labels]
medium_priority = [i for i in backlog if "medium" in i.labels]
low_priority = [i for i in backlog if "low" in i.labels]

# 3. Создать Sprint Planning issue
github_issue.create(
    title="Sprint 23 Planning (2026-02-15)",
    body=f"""
## Sprint Capacity

Team: @russianoracle
Duration: 2 weeks

## High Priority ({len(high_priority)} issues)
{chr(10).join(f"- {i.number}: {i.title}" for i in high_priority[:5])}

## Medium Priority ({len(medium_priority)} issues)
{chr(10).join(f"- {i.number}: {i.title}" for i in medium_priority[:3])}

## Planning Notes
Total capacity: ~{len(high_priority) + len(medium_priority) // 2} issues

Generated automatically from backlog.
    """,
    labels=["sprint-planning", "automated"]
)

# 4. Назначить команду
github_issue.update(
    issue_number=sprint_plan_issue,
    assignees=["russianoracle"]
)

# 5. Создать Linear sprint
linear.create_sprint(
    name="Sprint 23",
    start_date="2026-02-15",
    issues=high_priority + medium_priority
)
```

**Выгоды:**
- ✅ Автоматическое планирование спринтов
- ✅ На основе реального backlog'а
- ✅ Никакого ручного копирования

---

## 7. 🔔 Notifications и reminders

**НОВОЕ:** Автоматические напоминания

```python
# GitHub MCP для умных notification'ов

# 1. Найти stale PRs
stale_prs = [
    pr for pr in github_pr.list(state="open")
    if (now - pr.created_at) > timedelta(days=14)
]

for pr in stale_prs:
    github_pr.create_comment(
        pull_number=pr.number,
        body=f"""
🔔 **Friendly reminder**

This PR has been open for {(now - pr.created_at).days} days.

Consider:
- Closing if no longer relevant
- Updating if still in progress
- Adding reviewers if needed
        """
    )

    # Добавить метку "stale"
    github_pr.update(
        pull_number=pr.number,
        labels=["stale"]
    )

# 2. Найти блокированные issues
blocked_issues = [
    i for i in github_issue.list(state="open")
    if "blocked" in i.labels
]

for issue in blocked_issues:
    # Найти связанный Linear issue
    linear_id = extract_linear_id(issue.title)

    # Проверить статус в Linear
    linear_status = linear.get_status(linear_id)

    # Если разблокирован в Linear, обновить GitHub
    if linear_status != "blocked":
        github_issue.update(
            issue_number=issue.number,
            state="open",  # reopen
            labels.remove("blocked")
        )
```

**Выгоды:**
- ✅ Автоматические напоминания
- ✅ Синхронизация статусов GitHub ↔ Linear
- ✅ Никаких forgotten tasks

---

## 8. 📊 Analytics и reporting

**НОВОЕ:** Автоматическая генерация отчетов

```python
# GitHub MCP для аналитики

# 1. Еженедельный отчет о PRs
prs_this_week = github_pr.list(
    state="closed",
    sort="updated",
    per_page=100
)

# 2. Статистика
merged = [p for p in prs_this_week if p.merged_at]
average_merge_time = calculate_avg_merge_time(merged)

# 3. Создать issue с отчетом
github_issue.create(
    title="Weekly PR Report (2026-02-09)",
    body=f"""
## PR Statistics

Total merged: {len(merged)}
Average merge time: {average_merge_time}

## By Author:
{author_stats_table}

## Longest running PRs:
{top_5_longest}

Generated by GitHub MCP automation.
    """,
    labels=["reports", "weekly"]
)

# 4. Опубликовать в Slack/Discord (через другие MCP)
```

**Выгоды:**
- ✅ Автоматические метрики
- ✅ Видимость прогресса
- ✅ Data-driven решения

---

## 9. 🤖 Issue triage automation

**НОВОЕ:** Автоматическая классификация issues

```python
# GitHub MCP для умного триажа

# 1. При создании нового issue
new_issues = github_issue.list(state="open", sort="created")

for issue in new_issues:
    # 2. Проанализировать issue (через AI или правила)
    if "bug" in issue.title.lower():
        github_issue.update(
            issue_number=issue.number,
            labels=["bug", "triage-needed"]
        )

        # Если критично, назначить автоматически
        if "critical" in issue.title.lower() or "production" in issue.title.lower():
            github_issue.update(
                issue_number=issue.number,
                assignees=["oncall"]
            )

            # Создать alert в Slack

    elif "feature" in issue.title.lower():
        github_issue.update(
            issue_number=issue.number,
            labels=["enhancement", "backlog"]
        )

        # Оценить сложность
        complexity = estimate_complexity(issue.body)
        if complexity == "high":
            github_issue.update(
                issue_number=issue.number,
                labels=["needs-estimation"]
            )
```

**Выгоды:**
- ✅ Автоматическая классификация
- ✅ Быстрое назначение критичных issues
- ✅ Consistent triage process

---

## 10. 🔐 Security automation

**НОВО:** Автоматические security checks

```python
# GitHub MCP для security

# 1. Проверять новые PRs на секреты
pr = github_pr.get(pull_number=123)
files = github_pr.list_files(pull_number=123)

for file in files:
    if file.filename in ["config/secrets.yml", ".env"]:
        # Проверить что changed файлы не содержат секреты
        content = github_repository.read_file(
            path=file.filename,
            ref=f"refs/pull/{123}/head"
        )

        if detect_secrets(content):
            # Блокировать merge
            github_pr.create_review(
                pull_number=123,
                body="⚠️ **Potential secrets detected in {file.filename}**",
                event="REQUEST_CHANGES"
            )

            # Создать issue security
            github_issue.create(
                title="SECURITY: Secrets detected in PR #123",
                body="Found potential secrets in {file.filename}",
                labels=["security", "critical"]
            )

# 2. Проверять зависимости на known vulnerabilities
deps = check_dependencies_vulnerabilities()

if deps.critical:
    github_issue.create(
        title="Security: Critical vulnerabilities in dependencies",
        body=deps.report,
        labels=["security", "critical"]
    )
```

**Выгоды:**
- ✅ Автоматическая security проверка
- ✅ Блокировка небезопасных PRs
- ✅ Уведомления об уязвимостях

---

## 📊 Summary: Возможности автоматизации

| Workflow                   | Текущее состояние | Что добавить с GitHub MCP            |
|----------------------------|-------------------|----------------------------------------|
| cleanup.yml                | Ручной           | Auto-delete old merged branches      |
| dependency-tracker.yml   | Notifications     | Auto-update dependencies + PRs      |
| release-notes.yml          | Полу-авто        | Полностью автоматические notes       |
| claude-code-review.yml     | On-demand        | Auto-review on label trigger        |
| linear-sync.yml            | Linear → GitHub  | GitHub → Linear (双向同步)           |
| sprint-planning.yml        | Manual           | Auto-create sprint plans            |
| -                          | -                 | Auto-reminders for stale PRs       |
| -                          | -                 | Weekly/monthly reports             |
| -                          | -                 | Auto-triage issues                  |
| -                          | -                 | Security checks on PRs              |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🎯 Priority Matrix

| Автоматизация                    | Сложность | Ценность | Priority |
|------------------------------------|----------|---------|----------|
| Auto-delete merged branches         | ⭐⭐      | ⭐⭐⭐   | HIGH     |
| Auto-update dependencies             | ⭐⭐⭐⭐   | ⭐⭐⭐⭐  | URGENT   |
| Auto-release notes                  | ⭐⭐⭐     | ⭐⭐⭐⭐  | HIGH     |
| Auto-code review                    | ⭐⭐⭐⭐   | ⭐⭐⭐⭐  | MEDIUM   |
| Improved Linear sync                | ⭐⭐⭐     | ⭐⭐⭐    | MEDIUM   |
| Auto-sprint planning                | ⭐⭐⭐     | ⭐⭐⭐    | LOW      |
| Stale PR reminders                  | ⭐⭐      | ⭐⭐     | LOW      |
| Weekly reports                      | ⭐⭐      | ⭐⭐     | LOW      |
| Auto-triage                         | ⭐⭐⭐     | ⭐⭐⭐    | MEDIUM   |
| Security checks                     | ⭐⭐⭐⭐   | ⭐⭐⭐⭐  | URGENT   |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 💡 Мои рекомендации

### СРОЧНО (Priority 1):
1. **Auto-update dependencies** - сразу даст пользу
2. **Auto-delete merged branches** - чистота репозитория
3. **Security checks** - важно для безопасности

### СРЕДНЕСРОЧНО (Priority 2):
4. **Auto-code review** - ускорит code review
5. **Auto-release notes** - сэкономит время
6. **Improved Linear sync** - лучшая синхронизация

### ПОЗЖЕ (Priority 3):
7. Auto-sprint planning
8. Stale PR reminders
9. Weekly reports
10. Auto-triage

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Total potential:** ~10 новых автоматизаций с GitHub MCP!

Что реализуем первым?
