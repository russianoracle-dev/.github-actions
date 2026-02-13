---
name: complex-task-orchestration-with-validation
description: Orchestrates complex tasks through intelligent planning, budget-aware execution, parallel processing, smart caching, and proactive optimization with continuous validation and quality control.
agent: agent
---
```mermaid
flowchart TD
    start_node_default([Start])
    prompt_1768581229247[Используя лучшие навыки и з...]
    agent_complexity_assessor[agent-complexity-assessor]
    switch_complexity_level{Switch}
    end_node_simple_fasttrack([End])
    agent_requirements_analyzer[agent-requirements-analyzer]
    agent_cost_tracker[agent-cost-tracker]
    ask_requirements_approval{Question: Согласны ли вы с выявленными требованиями, ограничениями и допущениями?}
    agent_requirements_refinement[agent-requirements-refinement]
    agent_1768581600298[agent-1768581600298]
    agent_tradeoff_analyzer[agent-tradeoff-analyzer]
    ask_model_approval{Question: Выберите модель для выполнения задачи (учитывая tradeoffs по качеству и стоимости):}
    ask_solution_approach{Question: Выберите предпочтительный подход к решению задачи:}
    agent_auto_execution[agent-auto-execution]
    agent_collaborative_execution[agent-collaborative-execution]
    agent_stepwise_execution[agent-stepwise-execution]
    agent_billing_checkpoint[agent-billing-checkpoint]
    agent_budget_monitor[agent-budget-monitor]
    switch_budget_status{Switch}
    ask_budget_warning_yellow{Question: ⚠️ ПРЕДУПРЕЖДЕНИЕ: Использовано 70-85% бюджета.

{{budget_monitor_output}}

Как продолжить?}
    ask_budget_warning_orange{Question: 🚨 КРИТИЧЕСКОЕ ПРЕДУПРЕЖДЕНИЕ: Использовано 85-95% бюджета!

{{budget_monitor_output}}

Необходимо принять решение:}
    ask_budget_warning_red{Question: 🛑 ЭКСТРЕННОЕ ПРЕДУПРЕЖДЕНИЕ: Использовано >95% бюджета! Приближается HARD STOP!

{{budget_monitor_output}}

Выполнение будет остановлено при достижении 100%. Действия:}
    agent_scope_phasing[agent-scope-phasing]
    agent_emergency_optimizer[agent-emergency-optimizer]
    end_node_budget_exceeded([End])
    if_cost_threshold{Condition}
    ask_continue_approval{Question: Прогнозируемая стоимость превышает установленный порог. Продолжить выполнение?}
    agent_cost_optimizer[agent-cost-optimizer]
    agent_result_validator[agent-result-validator]
    agent_iteration_counter[agent-iteration-counter]
    if_validation_result{Condition}
    if_iteration_limit{Condition}
    agent_quality_integrator[agent-quality-integrator]
    ask_user_satisfaction{Question: Результаты не полностью соответствуют критериям приемки. Удовлетворяет ли вас текущий результат?}
    ask_limit_reached_decision{Question: Достигнут лимит итераций доработки (3). Как продолжить?}
    agent_refinement[agent-refinement]
    agent_counter_reset[agent-counter-reset]
    agent_final_billing_report[agent-final-billing-report]
    skill_1768581199446[[Skill: skill-navigator]]
    end_node_default([End])
    end_node_abort([End])

    start_node_default --> prompt_1768581229247
    prompt_1768581229247 --> agent_complexity_assessor
    agent_complexity_assessor --> switch_complexity_level
    switch_complexity_level --> end_node_simple_fasttrack
    switch_complexity_level --> agent_requirements_analyzer
    agent_requirements_analyzer --> agent_cost_tracker
    agent_cost_tracker --> ask_requirements_approval
    ask_requirements_approval --> agent_1768581600298
    ask_requirements_approval --> agent_requirements_refinement
    agent_requirements_refinement --> ask_requirements_approval
    agent_1768581600298 --> agent_tradeoff_analyzer
    agent_tradeoff_analyzer --> ask_model_approval
    ask_model_approval --> ask_solution_approach
    ask_model_approval --> ask_solution_approach
    ask_model_approval --> ask_solution_approach
    ask_solution_approach --> agent_auto_execution
    ask_solution_approach --> agent_collaborative_execution
    ask_solution_approach --> agent_stepwise_execution
    agent_auto_execution --> agent_billing_checkpoint
    agent_collaborative_execution --> agent_billing_checkpoint
    agent_stepwise_execution --> agent_billing_checkpoint
    agent_billing_checkpoint --> agent_budget_monitor
    agent_budget_monitor --> switch_budget_status
    switch_budget_status --> if_cost_threshold
    switch_budget_status --> ask_budget_warning_yellow
    switch_budget_status --> ask_budget_warning_orange
    switch_budget_status --> ask_budget_warning_red
    switch_budget_status --> if_cost_threshold
    ask_budget_warning_yellow --> if_cost_threshold
    ask_budget_warning_yellow --> agent_cost_optimizer
    ask_budget_warning_yellow --> agent_scope_phasing
    ask_budget_warning_orange --> agent_emergency_optimizer
    ask_budget_warning_orange --> agent_scope_phasing
    ask_budget_warning_orange --> if_cost_threshold
    ask_budget_warning_orange --> end_node_budget_exceeded
    ask_budget_warning_red --> if_cost_threshold
    ask_budget_warning_red --> agent_emergency_optimizer
    ask_budget_warning_red --> end_node_budget_exceeded
    agent_scope_phasing --> if_cost_threshold
    agent_emergency_optimizer --> if_cost_threshold
    if_cost_threshold --> agent_result_validator
    if_cost_threshold --> ask_continue_approval
    ask_continue_approval --> agent_result_validator
    ask_continue_approval --> agent_cost_optimizer
    agent_cost_optimizer --> agent_result_validator
    agent_result_validator --> agent_iteration_counter
    agent_iteration_counter --> if_validation_result
    if_validation_result --> agent_quality_integrator
    if_validation_result --> if_iteration_limit
    if_iteration_limit --> ask_user_satisfaction
    if_iteration_limit --> ask_limit_reached_decision
    ask_user_satisfaction --> agent_quality_integrator
    ask_user_satisfaction --> agent_refinement
    ask_limit_reached_decision --> agent_quality_integrator
    ask_limit_reached_decision --> agent_counter_reset
    agent_counter_reset --> agent_requirements_refinement
    ask_limit_reached_decision --> end_node_abort
    agent_refinement --> agent_result_validator
    agent_quality_integrator --> agent_final_billing_report
    agent_final_billing_report --> skill_1768581199446
    skill_1768581199446 --> end_node_default
```

# Workflow Execution Instructions

Follow the flowchart above to execute this workflow. Each node represents a step to perform.

## Prompts

### start-complex-task

```
Используя лучшие навыки и задействуя компетентных агентов выполни комплексную задачу: {{task}}   

```

## Sub-Agents

### agent-complexity-assessor

**Description**: Task complexity assessment

**Prompt**:
```
Оцени сложность задачи {{task}}:
1. Простая (1-2 этапа, базовые операции)
2. Средняя (3-5 этапов, требует координации)
3. Сложная (6+ этапов, множественные зависимости)

Предложи оптимальную стратегию выполнения и оцени ожидаемую стоимость (в токенах).
```

### agent-requirements-analyzer

**Description**: Requirements analysis

**Prompt**:
```
Проанализируй задачу {{task}} и выяви:
1. Требования (что должно быть достигнуто)
2. Ограничения (технические, временные, ресурсные)
3. Допущения (что можем предположить)
4. Критерии приемки (как измерить успех)

Подготовь варианты для обсуждения с пользователем.
```

### agent-cost-tracker

**Description**: Cost tracking and billing

**Prompt**:
```
Отслеживай использование ресурсов:
1. Подсчитай использованные токены на текущий момент
2. Оцени оставшуюся стоимость задачи
3. Сравни с бюджетными порогами (низкий: <10k, средний: 10k-50k, высокий: >50k)
4. Предложи возможности экономии (использование haiku, сокращение промптов, кэширование)

Верни детальный отчет по биллингу.
```

### agent-requirements-refinement

**Description**: Requirements refinement

**Prompt**:
```
На основе обратной связи пользователя уточни и скорректируй требования, ограничения и допущения. Запроси дополнительную информацию если необходимо.
```

### agent-1768581600298

**Description**: orchestrator 

**Prompt**:
```
Проанализируй задачу {{task}}, подбеори самые лучшие навыки и агентов, создай todo list запланиируй выполнение, коордириуй выполнение, контролируй выполнение, валидируй результаты перед приемкой, интегрриуй результаты и выполняй контроль качества интегрального результата!      
```

### agent-tradeoff-analyzer

**Description**: Cost-quality tradeoff analysis

**Prompt**:
```
Проанализируй tradeoffs для выполнения:
1. Опция A: использовать opus (высокое качество, высокая стоимость)
2. Опция B: использовать sonnet (баланс качества и стоимости)
3. Опция C: использовать haiku (базовое качество, низкая стоимость)

Для каждой опции укажи: ожидаемое качество (%), стоимость в токенах, время выполнения, риски.
```

### agent-auto-execution

**Description**: Automatic execution

**Prompt**:
```
Выполни задачу автоматически, используя оптимальные навыки и субагентов. Сохраняй точки восстановления на каждом этапе. Создай интерактивный TODO list с прогрессом выполнения.
```

### agent-collaborative-execution

**Description**: Collaborative execution

**Prompt**:
```
Предложи варианты решения задачи с описанием субагентов и навыков. Запроси согласование подхода перед началом выполнения. Сохраняй точки восстановления.
```

### agent-stepwise-execution

**Description**: Step-by-step execution

**Prompt**:
```
Выполняй задачу пошагово, запрашивая подтверждение после каждого значимого этапа. Создай детальный TODO list с возможностью отката к предыдущим точкам восстановления.
```

### agent-billing-checkpoint

**Description**: Billing checkpoint

**Prompt**:
```
Проведи промежуточный анализ расходов:
1. Текущие затраты токенов
2. Прогноз до завершения
3. Превышение бюджетных порогов
4. Рекомендации по оптимизации

Если прогноз превышает высокий порог (>50k токенов), запроси подтверждение продолжения.
```

### agent-budget-monitor

**Description**: Proactive budget monitoring

**Prompt**:
```
Проактивный мониторинг бюджета с ранним предупреждением:

1. Рассчитай процент использования бюджета: (текущие_токены / budget_limit) * 100
2. Определи уровень предупреждения:
   - GREEN (<70%): В рамках бюджета
   - YELLOW (70-85%): Приближается к лимиту - требуется внимание
   - ORANGE (85-95%): Критическое приближение - нужна оптимизация
   - RED (>95%): Экстренное предупреждение - скоро hard stop

3. Для YELLOW/ORANGE/RED предложи:
   - План оптимизации (замена моделей, кэширование, сокращение промптов)
   - Варианты фазирования скоупа (разбивка на этапы)
   - Приоритезация задач (что выполнить обязательно, что отложить)

Верни JSON:
```json
{
  "budget_status": "GREEN" | "YELLOW" | "ORANGE" | "RED",
  "usage_percent": <number>,
  "tokens_used": <number>,
  "tokens_remaining": <number>,
  "estimated_tokens_needed": <number>,
  "warning_message": "...",
  "optimization_plan": [...],
  "scope_phasing_options": [...],
  "task_prioritization": {...}
}
```
```

### agent-scope-phasing

**Description**: Scope phasing planner

**Prompt**:
```
Создай план фазирования скоупа задачи:

1. Раздели задачу на фазы по приоритету:
   - Phase 1 (Must Have): Критичный функционал
   - Phase 2 (Should Have): Важный функционал
   - Phase 3 (Nice to Have): Дополнительный функционал

2. Для каждой фазы укажи:
   - Оценку токенов
   - Критерии приемки
   - Зависимости от других фаз

3. Предложи стратегию:
   - Выполнить Phase 1 сейчас
   - Оценить бюджет после Phase 1
   - Решить о продолжении Phase 2/3

Верни структурированный план фазирования.
```

### agent-emergency-optimizer

**Description**: Emergency cost optimization

**Prompt**:
```
Экстренная оптимизация для возврата в бюджет:

1. Немедленные меры:
   - Переключить все возможные агенты на haiku
   - Включить агрессивное кэширование
   - Сократить промпты до минимума
   - Отключить детальное логирование

2. Приоритезация:
   - Определи MUST-HAVE задачи
   - Отложи NICE-TO-HAVE задачи
   - Упрости SHOULD-HAVE задачи

3. Рассчитай новую оценку:
   - Ожидаемая экономия токенов
   - Новый прогноз завершения
   - Компромиссы по качеству

Верни план экстренной оптимизации с новыми оценками.
```

### agent-cost-optimizer

**Description**: Cost optimization

**Prompt**:
```
Оптимизируй выполнение для снижения стоимости:
1. Замени сложные промпты на более эффективные
2. Используй кэширование результатов
3. Переключи некритичные задачи на haiku
4. Объедини похожие запросы

Сохрани качество на приемлемом уровне.
```

### agent-result-validator

**Description**: Result validation

**Prompt**:
```
Валидируй результаты работы субагентов согласно критериям приемки:
1. Проверь соответствие требованиям
2. Проверь качество выполнения
3. Проверь полноту решения

Если критерии не выполнены, подготовь детальный отчет о несоответствиях.
```

### agent-iteration-counter

**Description**: Iteration limit control

**Prompt**:
```
Отслеживай количество итераций доработки. Лимит: 3 итерации. Если лимит достигнут, предложи:
1. Принять текущий результат
2. Пересмотреть критерии приемки
3. Прервать выполнение

Верни: текущую итерацию, статус лимита, рекомендации.
```

### agent-quality-integrator

**Description**: Quality integration

**Prompt**:
```
Интегрируй результаты работы всех субагентов. Выполни финальный контроль качества:
1. Проверь согласованность результатов
2. Проверь отсутствие конфликтов
3. Создай итоговый отчет
4. Подготовь финальную документацию
```

### agent-refinement

**Description**: Result refinement

**Prompt**:
```
Доработай результаты согласно выявленным несоответствиям критериям приемки. Используй сохраненные точки восстановления для оптимизации процесса. Обеспечь соответствие всем требованиям качества.
```

### agent-counter-reset

**Description**: Counter reset

**Prompt**:
```
Сброс счетчика итераций уточнения требований.

Верни JSON:
```json
{
  "iteration_count": 0,
  "limit_reached": false,
  "status": "reset_complete"
}
```
```

### agent-final-billing-report

**Description**: Final billing report

**Prompt**:
```
Создай финальный отчет по биллингу:
1. Общее использование токенов
2. Разбивка по этапам и агентам
3. Стоимость в USD (по текущим расценкам)
4. Возможности оптимизации для будущего
5. ROI анализ (стоимость vs ценность результата)

Формат: структурированный отчет с графиками.
```

## User Questions

### ask-requirements-approval

**Question**: Согласны ли вы с выявленными требованиями, ограничениями и допущениями?

**Options**:
- **Согласен**: Требования корректны, продолжить выполнение
- **Требует уточнения**: Нужно обсудить и скорректировать требования

### ask-model-approval

**Question**: Выберите модель для выполнения задачи (учитывая tradeoffs по качеству и стоимости):

**Options**:
- **Opus (премиум)**: Максимальное качество, высокая стоимость
- **Sonnet (баланс)**: Оптимальное соотношение качества и стоимости
- **Haiku (экономия)**: Базовое качество, минимальная стоимость

### ask-solution-approach

**Question**: Выберите предпочтительный подход к решению задачи:

**Options**:
- **Автоматический**: Координатор выбирает оптимальный подход автоматически
- **С согласованием**: Координатор предлагает варианты для вашего утверждения
- **Пошаговый**: Выполнение с подтверждением каждого этапа

### ask-budget-warning-yellow

**Question**: ⚠️ ПРЕДУПРЕЖДЕНИЕ: Использовано 70-85% бюджета.

{{budget_monitor_output}}

Как продолжить?

**Options**:
- **Продолжить как есть**: Продолжить без изменений, принимая риск превышения
- **Применить оптимизацию**: Применить план оптимизации для снижения расходов
- **Фазировать скоуп**: Разбить задачу на этапы с промежуточными результатами

### ask-budget-warning-orange

**Question**: 🚨 КРИТИЧЕСКОЕ ПРЕДУПРЕЖДЕНИЕ: Использовано 85-95% бюджета!

{{budget_monitor_output}}

Необходимо принять решение:

**Options**:
- **Экстренная оптимизация**: Применить все меры оптимизации немедленно
- **Приоритезация + фазирование**: Выполнить только приоритетные задачи, остальное отложить
- **Увеличить бюджет**: Продолжить с увеличенным бюджетным лимитом
- **Остановить выполнение**: Остановить и сохранить текущий прогресс

### ask-budget-warning-red

**Question**: 🛑 ЭКСТРЕННОЕ ПРЕДУПРЕЖДЕНИЕ: Использовано >95% бюджета! Приближается HARD STOP!

{{budget_monitor_output}}

Выполнение будет остановлено при достижении 100%. Действия:

**Options**:
- **Увеличить лимит СРОЧНО**: Немедленно увеличить бюджетный лимит для продолжения
- **Завершить минимальный скоуп**: Быстро завершить критичные задачи и остановиться
- **Hard stop сейчас**: Немедленно остановить и сохранить результаты

### ask-continue-approval

**Question**: Прогнозируемая стоимость превышает установленный порог. Продолжить выполнение?

**Options**:
- **Продолжить**: Продолжить выполнение несмотря на превышение бюджета
- **Оптимизировать**: Применить меры по снижению стоимости

### ask-user-satisfaction

**Question**: Результаты не полностью соответствуют критериям приемки. Удовлетворяет ли вас текущий результат?

**Options**:
- **Принять**: Результат приемлем, несмотря на отклонения
- **Доработать**: Требуется доработка для соответствия критериям

### ask-limit-reached-decision

**Question**: Достигнут лимит итераций доработки (3). Как продолжить?

**Options**:
- **Принять результат**: Завершить с текущим результатом
- **Пересмотреть критерии**: Скорректировать критерии приемки и продолжить
- **Прервать**: Остановить выполнение

## Skills

### skill-navigator

**Description**: The 100th skill! Your intelligent guide to all 99 other skills. Recommends the perfect skill for any task, creates skill combinations, and helps you discover capabilities you didn't know you had.

**Path**: `/Users/artemgusarov/.claude/skills/skill-navigator/SKILL.md`
