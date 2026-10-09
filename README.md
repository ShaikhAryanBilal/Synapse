# Synapse — Multi-Agent Skill Orchestrator

A single installable skill for AI coding agents (OpenCode, Claude Code, Codex
CLI, Gemini CLI). It contains an orchestrator plus every specialist workflow —
implementation, security, testing, planning, research, docs, git, parsing, and
memory — in one file.

```
Foresight → Coder → Sentinel → Tester
  Analyze    Implement   Audit     Verify
```

Everything lives in **[`synapse.md`](./synapse.md)**. This README is the only
other file.

---

## What's inside

| Specialist | Domain |
|------------|--------|
| **Orchestrator** | Routes tasks; runs the full pipeline |
| **Foresight** | Pre-development risk & edge-case analysis |
| **Coder** | Writes, debugs, refactors code |
| **Sentinel** | Security audits, pentesting, OWASP/CWE |
| **Tester** | Property testing, fuzzing, coverage, CI gates |
| **Planner** | Roadmaps, decomposition, dependency graphs |
| **Scout** | Web search, docs lookup, live data |
| **Scholar** | Deep research, multi-source synthesis |
| **Guardian** | Git, branches, commits, changelogs, PR review |
| **Writer** | Docs, READMEs, API references, ADRs |
| **Keeper** | Cross-session memory & context persistence |
| **Parser** | OCR, logs, structured-data extraction |

---

## Install

`synapse.md` is a standard Agent Skill file. To make an agent discover it,
place it where the agent scans for skills, as a `SKILL.md` inside a `synapse`
folder.

**Global (all projects)**

```bash
# macOS / Linux
mkdir -p ~/.agents/skills/synapse ~/.claude/skills/synapse
cp synapse.md ~/.agents/skills/synapse/SKILL.md   # OpenCode, Codex CLI, Gemini CLI
cp synapse.md ~/.claude/skills/synapse/SKILL.md   # Claude Code
```

```powershell
# Windows
New-Item -ItemType Directory -Force "$env:USERPROFILE\.agents\skills\synapse" | Out-Null
Copy-Item synapse.md "$env:USERPROFILE\.agents\skills\synapse\SKILL.md"
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\skills\synapse" | Out-Null
Copy-Item synapse.md "$env:USERPROFILE\.claude\skills\synapse\SKILL.md"
```

**Per-project**

```bash
mkdir -p .agents/skills/synapse .claude/skills/synapse
cp synapse.md .agents/skills/synapse/SKILL.md
cp synapse.md .claude/skills/synapse/SKILL.md
```

Prefer a link so edits stay in sync (use a junction on Windows:

`New-Item -ItemType Junction -Path "<skills>/synapse/SKILL.md" -Target "<repo>/synapse.md"`).

Some agents (OpenCode) also accept the file directly — drop `synapse.md` into
the agent's skills directory.

---

## Usage

Once installed, describe what you need. Examples:

| Prompt | What happens |
|--------|-------------|
| "Implement a payment gateway" | Pipeline: Foresight → Coder → Sentinel → Tester |
| "Fix this bug" | Coder (quick mode) |
| "Audit the API for security" | Sentinel |
| "Build a login system, full pipeline" | Foresight → Coder → Sentinel → Tester |
| "(quick) rename this variable" | Coder skips reconnaissance |
| "Research X, then plan and build it" | Scholar → Planner → Coder → Tester |

Agents discover the skill automatically — no manual loading required. The
orchestrator picks the right specialist and chains them for complex work. See
`synapse.md` for the full routing tree, pipeline, per-specialist workflows, and
the global response-contract rule.

---

## Editing

Edit `synapse.md` directly — it is the single source of truth. Re-copy or
re-link it to your agents' skills directories after changes.

---

## License

MIT
