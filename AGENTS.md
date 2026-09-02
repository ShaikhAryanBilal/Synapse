# Synapse — Multi-Agent Skill Orchestrator

> Unified skill system for AI coding agents (OpenCode, Claude Code, Codex CLI, Gemini CLI).
> Routes domain-specific tasks to the right specialist skill via a lightweight orchestrator.
> Supports the full pipeline: **Foresight → Coder → Sentinel → Tester**

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│                   User Prompt                    │
└──────────────────────┬──────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────┐
│            synapse-core (Orchestrator)           │
│  ─ Analyzes intent → selects skill → dispatches │
└──┬────┬────┬────┬────┬────┬────┬────┬────┬────┬─┘
   │    │    │    │    │    │    │    │    │    │
   ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│FORESIGHT │ │  CODER   │ │ SENTINEL │ │  TESTER  │ │ PLANNER  │ │  SCOUT   │ │ SCHOLAR  │ │GUARDIAN  │ │  WRITER  │ │  PARSER  │
└──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘
```

---

## Execution Pipeline

For complex tasks, skills execute in order:

```
Foresight ──► Coder ──► Sentinel ──► Tester
  │            │            │            │
 Analyze    Implement    Audit       Verify
```

Each stage feeds its output to the next. Any stage can reject or re-route.

---

## Skill Registry

| Skill | Domain | Role | Tools |
|-------|--------|------|-------|
| `synapse-core` | Orchestration | Orchestrator | skill + task + read |
| `synapse-foresight` | Analysis | Architect | read, write |
| `synapse-coder` | Implementation | Engineer | read, write, edit, bash, glob, grep |
| `synapse-sentinel` | Security | Auditor | read, write, bash, glob, grep |
| `synapse-tester` | QA | Tester | read, write, edit, bash, glob, grep |
| `synapse-planner` | Strategy | Architect | read, write |
| `synapse-scout` | Web | Scout | webfetch, websearch, read |
| `synapse-scholar` | Research | Researcher | read, webfetch, websearch, grep |
| `synapse-guardian` | Git | Guardian | bash, read |
| `synapse-writer` | Docs | Writer | read, write, edit |
| `synapse-pipeline` | Orchestration | Runner | skill + task + read |
| `synapse-keeper` | Memory | Steward | read, write, bash |
| `synapse-parser` | Data | Parser | read, bash |

**Total: 13 skills**

---

## Routing Logic

The orchestrator (`synapse-core`) uses this decision tree:

```
 1. Pre-development risk/edge-case analysis?  → synapse-foresight
 2. Security/auditing/pentest?                 → synapse-sentinel
 3. Web research/data gathering?               → synapse-scout / synapse-scholar
 4. Planning/architecture/strategy?             → synapse-planner
 5. Documentation/writing?                      → synapse-writer
 6. Git/version control?                        → synapse-guardian
 7. Testing/QA/coverage?                        → synapse-tester
 8. Data parsing/OCR?                           → synapse-parser
 9. Memory/context persistence?                 → synapse-keeper
10. Implementation/coding?                      → synapse-coder
```

**Pipeline mode (complex tasks):**
```
Foresight → Coder → Sentinel → Tester
```

---

## Pipeline Examples

| Task | Pipeline |
|------|----------|
| "Implement payment gateway" | foresight → coder → sentinel → tester |
| "Add API auth" | foresight → coder → sentinel → tester |
| "Fix security vuln" | sentinel → coder → tester → sentinel |
| "Build new feature" | planner → coder → tester |
| "Audit dependencies" | sentinel → tester |

---

## Response Contract Integrity (Non-Negotiable)

Whenever a change touches code that **produces, shapes, or returns data to a consumer** — API endpoints, serializers, DTOs/mappers, view models, GraphQL resolvers, JSON builders — the agent MUST:

1. **Snapshot the contract BEFORE** editing: enumerate every key/field the consumer relies on, along with its type and required/optional status.
2. **Verify the contract AFTER** editing: diff the response shape against the pre-edit snapshot.
3. **Never ship a silently dropped or renamed key.** A missing or renamed key breaks the frontend and downstream consumers without any obvious error.

Any intentional contract change (removed/renamed key, type change) must be surfaced explicitly as a **breaking change** with the affected consumers named. Back this up with a contract/snapshot test so a dropped key fails CI instead of breaking production.

This rule is enforced in `synapse-coder` (BEFORE/AFTER diff), `synapse-tester` (contract tests), and `synapse-foresight` (contract-drift risk).

---

## Single Source of Truth

All skill files live in **`./skills/<name>/SKILL.md`** — one copy, edited in place.
The repo contains no agent directories and no duplicates. Each agent is pointed at
that directory from outside the repo via a junction/symlink (or a copy):

| Agent | Where it looks | Point at |
|-------|----------------|----------|
| OpenCode | `.agents/skills/` (project), `~/.agents/skills/` (global) | `./skills` |
| Claude Code | `.claude/skills/` (project), `~/.claude/skills/` (global) | `./skills` |
| Codex CLI | `.agents/skills/` (repo root), `~/.agents/skills/` (global) | `./skills` |
| Gemini CLI | `.agents/skills/` (workspace), `~/.gemini/skills/` (global) | `./skills` |

Install with the scripts (global or per-project, link or copy):

```bash
./scripts/install.sh --all-agents                    # macOS/Linux  (global)
.\scripts\install.ps1 -AllAgents                     # Windows      (global)
./scripts/install.sh --project-dir ../MyProject      # macOS/Linux  (per-project)
.\scripts\install.ps1 -ProjectDir ..\MyProject       # Windows      (per-project)
```

All skills comply with the [Agent Skills specification](https://agentskills.io/specification).

---

## Usage

Skills live in one place — `./skills/`. Point your agent at it (no copies in this repo):

```bash
# Global — every project
ln -s "$PWD/skills" ~/.agents/skills      # OpenCode, Codex CLI, Gemini CLI
ln -s "$PWD/skills" ~/.claude/skills      # Claude Code

# Per-project
ln -s "$PWD/skills" ../MyProject/.agents/skills
ln -s "$PWD/skills" ../MyProject/.claude/skills
```

---

## License

MIT
