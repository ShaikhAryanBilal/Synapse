# Synapse — Multi-Agent Skill Orchestrator

**13 skills** for AI coding agents (OpenCode, Claude Code, Codex CLI, Gemini CLI).
Routes domain-specific tasks to specialist skills via a lightweight orchestrator.

Skills live in **one place only**: `./skills/`. The repo contains no agent
directories and no copies — every agent is pointed at this single directory
from **outside** the repo (via a junction/symlink or a copy), as described below.

```
./skills/  ──►  ~/.agents/skills   (global link)  →  OpenCode, Codex CLI, Gemini CLI
                 ~/.claude/skills  (global link)  →  Claude Code
```

---

## Install

### 1. Global (skills available in every project)

Point each agent's global skills directory at this repo's `./skills`. Prefer
**linking** (stays in sync) or **copy** (self-contained install).

```bash
# macOS / Linux
./scripts/install.sh --all-agents        # link for OpenCode + Claude Code + Codex + Gemini
./scripts/install.sh --all-agents --copy # or copy instead of linking

# Windows
.\scripts\install.ps1 -AllAgents
.\scripts\install.ps1 -AllAgents -Copy
```

Per-agent flags: `--opencode` / `--claude-code` / `--codex` / `--gemini`
(`-OpenCode` / `-ClaudeCode` / `-Codex` / `-Gemini` on Windows).

### 2. Per-project (skills only in one project)

```bash
./scripts/install.sh --project-dir ../MyProject        # macOS / Linux
.\scripts\install.ps1 -ProjectDir ..\MyProject         # Windows
```

This creates `<project>/.agents/skills` and `<project>/.claude/skills` links
to `./skills`. Nothing is written inside this repo.

### 3. Manual / per-agent

Each agent needs its skills directory to resolve to `./skills`:

| Agent | What it has to do |
|-------|-------------------|
| **OpenCode** | OpenCode scans `.agents/skills/` (and `.opencode/skills/`). Link `.agents/skills` → `./skills`, or `~/.agents/skills` → `./skills` globally. |
| **Claude Code** | Claude Code scans `.claude/skills/` (project) and `~/.claude/skills/` (global). Link that dir → `./skills`. |
| **Codex CLI** | Codex scans `.agents/skills/` at repo root and `~/.agents/skills/` globally. Link the applicable one → `./skills`. |
| **Gemini CLI** | Gemini scans `.agents/skills/` in the workspace and `~/.gemini/skills/` globally. Link the applicable one → `./skills`. |

Example (macOS/Linux):

```bash
# Global, for OpenCode + Codex + Gemini
ln -s "$PWD/skills" ~/.agents/skills

# Global, for Claude Code
ln -s "$PWD/skills" ~/.claude/skills

# Per-project, for OpenCode + Codex + Gemini
ln -s "$PWD/skills" ../MyProject/.agents/skills

# Per-project, for Claude Code
ln -s "$PWD/skills" ../MyProject/.claude/skills
```

Windows equivalent (junctions, no admin needed):

```powershell
New-Item -ItemType Junction -Path "$env:USERPROFILE\.agents\skills" -Target "$PWD\skills"
New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\skills" -Target "$PWD\skills"
```

### 4. Git remote (agents that fetch skills directly)

```bash
# Claude Code — point at the repo:
claude "Install skills from https://github.com/ShaikhAryanBilal/Synapse"

# Codex CLI — fetch and link the skills folder:
codex --skill-dir https://github.com/ShaikhAryanBilal/Synapse/tree/main/skills
```

---

## Usage

After linking, just tell your agent what you need:

| Prompt | What happens |
|--------|-------------|
| "Implement a payment gateway" | Pipeline: Foresight → Coder → Sentinel → Tester |
| "Fix this bug" | Coder (quick mode) |
| "Audit the API for security" | Sentinel |
| "Build a login system, full pipeline" | 4 specialists, one prompt |
| "(quick) rename this variable" | Coder skips recon phase |

Your agent discovers skills automatically — no manual loading required.

---

## Skills

### Core 5 (recommended default)

| Skill | Domain | Role |
|-------|--------|------|
| **synapse-core** | Orchestration | Routes tasks to the right specialist |
| **synapse-foresight** | Analysis | Pre-development risk & edge-case analysis |
| **synapse-coder** | Implementation | Writes, debugs, refactors code |
| **synapse-sentinel** | Security | Pentesting, vulnerability scanning, OWASP Top 10 |
| **synapse-tester** | QA | Property-based testing, fuzzing, CI gates |

### Extras (opt-in)

| Skill | Domain | Role |
|-------|--------|------|
| **synapse-pipeline** | End-to-end | Loads all 4 pipeline stages as one skill |
| **synapse-planner** | Strategy | Roadmaps, architecture, planning |
| **synapse-scout** | Web | Search, browse, scrape |
| **synapse-scholar** | Research | Deep research, multi-source analysis |
| **synapse-guardian** | Git | Commits, branches, changelogs |
| **synapse-writer** | Docs | Technical writing, documentation |
| **synapse-keeper** | Memory | Cross-session context persistence |
| **synapse-parser** | Data | OCR, document parsing, extraction |

---

## Editing Skills

Edit files directly in `./skills/<name>/` — every agent reads the same source.
Links pick up changes on restart (or immediately for live-reload agents).
If you only want a subset, copy the individual `skills/<name>` folders manually.

---

## Pipeline

```
Foresight → Coder → Sentinel → Tester
  ↑           ↑         ↑         ↑
Analyze    Implement  Audit    Verify
```

Each stage feeds its output to the next. See `AGENTS.md` for details.

---

## License

MIT
