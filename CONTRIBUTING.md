# Contributing to Synapse

Thank you for considering contributing to Synapse. This guide covers how to add, modify, and test skills.

---

## Project Structure

```
synapse/
├── skills/
│   ├── synapse-<name>/
│   │   ├── SKILL.md          # Skill definition (frontmatter + workflow)
│   │   └── references/       # Optional reference docs
│   └── ...
├── scripts/
│   ├── install.sh            # macOS/Linux installer
│   └── install.ps1           # Windows installer
├── AGENTS.md                 # Architecture docs
├── README.md                 # User-facing docs
├── version.json              # Version and skill registry
└── CONTRIBUTING.md           # This file
```

---

## Adding a New Skill

### 1. Create the skill directory

```
skills/synapse-<name>/SKILL.md
```

### 2. Follow the SKILL.md template

Every skill must have this structure:

```yaml
---
name: synapse-<name>
description: <one-line description for agent discovery>
license: MIT
metadata:
  author: Synapse
  version: "1.0.0"
  domain: <domain>
  role: <role>
  scope: <scope>
  output-format: <format>
  related-skills: <list>
---
```

### 3. Required sections

Every SKILL.md must include:

| Section | Purpose |
|---------|---------|
| `## What I Do` | Plain English description of the skill's purpose |
| `## Triggers` | What prompts should activate this skill |
| `## Tools` | Which tools the skill uses |
| `## Workflow` | Multi-phase workflow with phase gates |
| `## Constraints` | Rules the skill MUST follow |

### 4. Workflow phases

Each workflow should have 3-6 phases, each with:
1. Clear objectives
2. Concrete steps
3. Output definition

### 5. Update the registry

Add the skill to:
- `version.json` in the `extraSkills` or `coreSkills` array
- `AGENTS.md` in the Skill Registry table
- `README.md` in the Skills section

---

## Modifying an Existing Skill

1. Read the current SKILL.md completely
2. Understand the workflow phases and constraints
3. Make changes that are backward-compatible when possible
4. Update the version in the frontmatter `metadata.version`
5. Test by loading the skill with your agent

### Version bumping

- **Patch** (1.0.x): typo fixes, constraint clarifications, example updates
- **Minor** (1.x.0): new phases, new triggers, expanded workflow
- **Major** (x.0.0): breaking changes to workflow, removed phases, changed output format

---

## Skill Quality Checklist

Before submitting a new or modified skill:

- [ ] Frontmatter is valid YAML with all required fields
- [ ] `## What I Do` is clear to someone unfamiliar with the domain
- [ ] `## Triggers` includes at least 3 trigger patterns
- [ ] `## Workflow` has at least 3 phases with defined outputs
- [ ] `## Constraints` includes MUST, MUST NOT, and SHOULD rules
- [ ] No references to files that don't exist
- [ ] Compatible with OpenCode, Claude Code, Codex CLI, and Gemini CLI
- [ ] Follows the [Agent Skills specification](https://agentskills.io/specification)

---

## Testing Skills

1. Install skills locally using the install scripts
2. Load the skill with your agent
3. Test with 3-5 representative prompts
4. Verify the workflow phases execute in order
5. Check that constraints are respected
6. Confirm output format matches the skill's output-format field

---

## Code Style

- Use `##` for top-level sections, `###` for subsections
- Use tables for structured data, lists for sequential steps
- Use code blocks with language tags for examples
- Keep descriptions concise — no walls of text
- Use consistent terminology across skills

---

## Pull Requests

1. Fork the repo and create a branch: `feat/<skill-name>` or `fix/<issue>`
2. Make your changes following the guidelines above
3. Update version.json if adding a new skill
4. Update AGENTS.md and README.md if adding a new skill
5. Test with at least one agent before submitting
6. Write a clear PR description explaining what changed and why

---

## Reporting Issues

Open an issue with:
- Skill name (if skill-specific)
- What you expected
- What actually happened
- Agent and version used
- Steps to reproduce
