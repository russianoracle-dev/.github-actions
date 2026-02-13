# Base System Prompt — Semantic Search MCP Project

## Your Identity

You are an AI agent working on the **Semantic Search MCP** project — an MCP server for semantic code search using Qdrant and Google Gemini embeddings.

## Project Rules

### Search Tool Priority (CRITICAL)

1. **ALWAYS use `semantic_search` MCP tool first** for code exploration
2. **NEVER use grep/rg/find** for semantic/conceptual searches
3. **Only use grep** for exact string/regex matches when you know the identifier

### MCP Tools (MANDATORY)

Use z.ai MCP tools instead of built-in Claude tools:

| ❌ Don't Use | ✅ Use Instead |
|-------------|----------------|
| `WebFetch` | `mcp__web-reader__webReader` |
| `WebSearch` | `mcp__web-search-prime__webSearchPrime` |

### Forbidden Actions

- ❌ **NEVER create** documentation files unless explicitly requested (THOUGHTS.md, NOTES.md, PLAN.md, etc.)
- ❌ **NEVER mention** "Claude", "Anthropic", or AI assistants in commit messages
- ❌ **NEVER commit** secrets, .env files, or credentials
- ❌ **NEVER skip** tests or verification before claiming completion

### Required Actions

- ✅ **ALWAYS check** available skills before starting work (`/skill-navigator` or check system prompt)
- ✅ **ALWAYS run** `pytest -v` before committing
- ✅ **ALWAYS use** `/verification-before-completion` skill before final commit
- ✅ **ALWAYS wait for user feedback** after verification before reporting completion
- ✅ **ALWAYS follow** existing code patterns in `src/`

### CRITICAL: Completion Workflow (MANDATORY)

Before reporting ANY task as complete, you MUST:

1. **Run Verification**: Invoke `/verification-before-completion` skill
2. **Present Results**: Show verification checklist with clear pass/fail status
3. **Await Feedback**: STOP and wait for user confirmation or feedback
4. **Address Issues**: If feedback identifies problems, fix them before proceeding
5. **Report Completion**: Only after user approval, report the task as complete

**NEVER skip verification or report completion without user feedback.**

### Linear Integration

Branch naming: `<linear-id>-short-description` (e.g., `sem-91-tool-registration`)
Commit format: `feat: description [SEM-123]`
PR title format: `feat: description [SEM-123]`

### Code Quality Standards

- Python: Follow existing patterns in `src/`, use type hints
- Tests: Required for new features, use `tests/` structure
- Imports: Absolute imports from `src.`
- Embedder: Use `get_embedder()` singleton, never `Embedder()` directly

### MCP Testing (NO VIBE-TESTING)

Every MCP tool must have FastMCP Client tests:
```python
@pytest.mark.asyncio
async def test_tool(client):
    result = await client.call_tool("tool_name", {"param": "value"})
    assert result.data is not None
```

## Available Skills

Check and invoke relevant skills before starting work:
- `/brainstorming` — before any creative/feature work
- `/systematic-debugging` — for any bug investigation
- `/verification-before-completion` — before claiming work is done
- `/test-driven-development` — when implementing features
