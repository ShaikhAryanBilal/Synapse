# Synapse — Multi-Agent Skill Orchestrator

**12 skills** for AI coding agents (OpenCode, Claude Code, Codex CLI, Gemini CLI).
Routes domain-specific tasks to specialist skills via a lightweight orchestrator.

## Quick Install (Core 5)

Most users only need **5 core skills**: `synapse-core`, `synapse-foresight`, `synapse-coder`, `synapse-sentinel`, `synapse-tester`. The other 7 are opt-in.

### Option A: Pass the repo URL to your agent (recommended)

```bash
# OpenCode — just tell your agent:
"Clone https://github.com/your-org/synapse into your skills directory"

# Or add this to your opencode.json:
{
  "skills": [
    "https://github.com/your-org/synapse/tree/main/skills/synapse-core",
    "https://github.com/your-org/synapse/tree/main/skills/synapse-foresight",
    "https://github.com/your-org/synapse/tree/main/skills/synapse-coder",
    "https://github.com/your-org/synapse/tree/main/skills/synapse-sentinel",
    "https://github.com/your-org/synapse/tree/main/skills/synapse-tester"
  ]
}
```

```bash
# Claude Code — pass repo URL:
claude "Install skills from https://github.com/your-org/synapse"

# Codex CLI — point to skills folder:
codex --skill-dir https://github.com/your-org/synapse/tree/main/skills
```

### Option B: Manual copy

```bash
# Core 5 only:
for s in synapse-core synapse-foresight synapse-coder synapse-sentinel synapse-tester; do
  cp -r "./skills/$s" ~/.config/opencode/skills/
done

# All 12:
cp -r ./skills/* ~/.config/opencode/skills/
cp -r ./skills/* ~/.claude/skills/
cp -r ./skills/* .agents/skills/
```

### Option C: Installer scripts

```bash
chmod +x scripts/install.sh && ./scripts/install.sh --core-5     # macOS/Linux
.\scripts\install.ps1 -Core5                                      # Windows
.\scripts\install.ps1 -AllAgents                                   # All 12
```

---

## Usage

After install, just tell your agent what you need:

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
