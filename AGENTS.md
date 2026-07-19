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
| `synapse-keeper` | Memory | Steward | read, write, bash |
| `synapse-parser` | Data | Parser | read, bash |

**Total: 12 skills**

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

## Cross-Platform Compatibility

| Location | Agent |
|----------|-------|
| `./skills/<name>/SKILL.md` | OpenCode, Claude Code, Codex |
| `.opencode/skills/<name>/SKILL.md` | OpenCode |
| `.claude/skills/<name>/SKILL.md` | Claude Code |
| `.agents/skills/<name>/SKILL.md` | OpenCode, compatible agents |

All skills comply with the [Agent Skills specification](https://agentskills.io/specification).

---

## Usage

```bash
# Install for OpenCode
cp -r ./skills/* ~/.config/opencode/skills/

# Install for Claude Code
cp -r ./skills/* ~/.claude/skills/

# Install project-local
cp -r ./skills/* .opencode/skills/

# Or use the installer scripts
./scripts/install.sh --all-agents     # macOS/Linux
.\scripts\install.ps1 -AllAgents     # Windows
```

---

## License

MIT
