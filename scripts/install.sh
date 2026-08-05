#!/usr/bin/env bash
# Synapse — Skill Installer (macOS / Linux)
# Skills live in ONE place: ./skills. This script points agents at that
# directory from OUTSIDE the repo — nothing is added to the repo itself.
#
#   Global  : link/copy the skills into your agent's global skills directory.
#   Project : link/copy the skills into a project's agent directories
#             (e.g. <project>/.agents/skills and <project>/.claude/skills).
#
# Usage:
#   ./scripts/install.sh --opencode                    # global, OpenCode (+Codex/Gemini via ~/.agents/skills)
#   ./scripts/install.sh --claude-code                 # global, Claude Code
#   ./scripts/install.sh --all-agents                  # global, all agents
#   ./scripts/install.sh --all-agents --copy           # copy instead of link
#   ./scripts/install.sh --project-dir ../MyProject    # point that project's agents at ./skills

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$SOURCE_DIR/skills"

OPENCODE_TARGET="$HOME/.agents/skills"
CLAUDE_TARGET="$HOME/.claude/skills"
CODEX_TARGET="$HOME/.agents/skills"
GEMINI_TARGET="$HOME/.agents/skills"

LINK=1
PROJECT_DIR=""
declare -a TARGETS=()

usage() {
  echo "Usage: $0 [--opencode] [--claude-code] [--codex] [--gemini] [--all-agents] [--copy] [--project-dir <path>]"
  echo "  --opencode      Point OpenCode's global skills dir at ./skills"
  echo "  --claude-code   Point Claude Code's global skills dir at ./skills"
  echo "  --codex         Point Codex CLI's global skills dir at ./skills"
  echo "  --gemini        Point Gemini CLI's global skills dir at ./skills"
  echo "  --all-agents    All of the above"
  echo "  --copy          Copy skills instead of linking (self-contained install)"
  echo "  --project-dir   Point a specific project's agent dirs at ./skills (ignores the agent flags)"
  echo ""
  echo "Examples:"
  echo "  $0 --all-agents"
  echo "  $0 --all-agents --copy"
  echo "  $0 --project-dir ../MyProject"
  exit 0
}

if [ $# -eq 0 ]; then
  usage
fi

while [ $# -gt 0 ]; do
  case "$1" in
    --opencode)    TARGETS+=("$OPENCODE_TARGET|OpenCode (global ~/.agents/skills)"); shift ;;
    --claude-code) TARGETS+=("$CLAUDE_TARGET|Claude Code (global ~/.claude/skills)"); shift ;;
    --codex)       TARGETS+=("$CODEX_TARGET|Codex CLI (global ~/.agents/skills)"); shift ;;
    --gemini)      TARGETS+=("$GEMINI_TARGET|Gemini CLI (global ~/.agents/skills)"); shift ;;
    --all-agents)
      TARGETS+=("$OPENCODE_TARGET|OpenCode (global ~/.agents/skills)")
      TARGETS+=("$CLAUDE_TARGET|Claude Code (global ~/.claude/skills)")
      shift
      ;;
    --project-dir)
      PROJECT_DIR="${2:-}"
      shift 2
      ;;
    --copy) LINK=0; shift ;;
    *) usage ;;
  esac
done

if [ -n "$PROJECT_DIR" ]; then
  if [ ! -d "$PROJECT_DIR" ]; then
    echo "ERROR: project directory not found: $PROJECT_DIR" >&2
    exit 1
  fi
  TARGETS=("$PROJECT_DIR/.agents/skills|Project $PROJECT_DIR - .agents/skills (OpenCode, Codex, Gemini)")
  TARGETS+=("$PROJECT_DIR/.claude/skills|Project $PROJECT_DIR - .claude/skills (Claude Code)")
fi

if [ ${#TARGETS[@]} -eq 0 ]; then
  usage
fi

if [ ! -d "$SKILLS_DIR" ]; then
  echo "ERROR: skills directory not found at $SKILLS_DIR" >&2
  exit 1
fi

SKILL_COUNT="$(ls -d "$SKILLS_DIR"/*/ 2>/dev/null | wc -l | tr -d ' ')"
seen=""
for entry in "${TARGETS[@]}"; do
  target="${entry%%|*}"
  label="${entry#*|}"

  # Skip already-processed duplicate targets (e.g. ~/.agents/skills for 3 agents)
  case ":$seen:" in
    *":$target:"*) continue ;;
  esac
  seen="$seen:$target"

  echo "Installing for $label ..."
  if [ "$LINK" -eq 0 ]; then
    mkdir -p "$target"
    for skill in "$SKILLS_DIR"/*/; do
      name="$(basename "$skill")"
      rm -rf "$target/$name"
      cp -r "$skill" "$target/$name"
    done
    echo "  OK - copied $SKILL_COUNT skills"
    continue
  fi

  if [ -L "$target" ]; then
    rm -f "$target"
    echo "  replacing stale symlink ..."
  elif [ -e "$target" ]; then
    echo "  WARNING: $target already exists and is not a symlink." >&2
    echo "  It may contain your own skills. Use --copy to merge, or back it up first." >&2
    echo "  Skipped." >&2
    continue
  fi

  mkdir -p "$(dirname "$target")"
  ln -s "$SKILLS_DIR" "$target"
  echo "  linked -> $SKILLS_DIR"
done

echo ""
echo "Done. Skills are served from the single source: $SKILLS_DIR"
if [ "$LINK" -eq 0 ]; then
  echo "A copy was placed in each target directory (independent of the repo)."
else
  echo "Links stay in sync with the repo but break if the repo is moved or deleted."
fi
echo "Restart your agent to discover the skills."
