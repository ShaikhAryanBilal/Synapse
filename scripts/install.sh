#!/usr/bin/env bash
# Synapse — Multi-Agent Skill Installer (macOS / Linux)
# Installs skills for OpenCode, Claude Code, and compatible agents

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$SOURCE_DIR/skills"

install_to() {
  local target="$1"
  local label="$2"
  echo "Installing to $label..."
  mkdir -p "$target"
  for skill in "$SKILLS_DIR"/*/; do
    local name
    name="$(basename "$skill")"
    rm -rf "$target/$name"
    cp -r "$skill" "$target/$name"
  done
  local count
  count="$(ls -d "$SKILLS_DIR"/*/ 2>/dev/null | wc -l | tr -d ' ')"
  echo "  → $count skills installed"
}

usage() {
  echo "Usage: $0 [--opencode] [--claude-code] [--all-agents] [--project-local]"
  echo "  --opencode       Install to OpenCode global skill directories"
  echo "  --claude-code    Install to Claude Code global skill directories"
  echo "  --all-agents     Install to all global agent directories"
  echo "  --project-local  Install project-local copies"
  echo ""
  echo "Examples:"
  echo "  $0 --all-agents"
  echo "  $0 --opencode --project-local"
  exit 0
}

if [ $# -eq 0 ]; then
  usage
fi

while [ $# -gt 0 ]; do
  case "$1" in
    --opencode)
      install_to "$HOME/.config/opencode/skills" "OpenCode (global)"
      install_to "$HOME/.agents/skills" "OpenCode (.agents global)"
      shift
      ;;
    --claude-code)
      install_to "$HOME/.claude/skills" "Claude Code (global)"
      shift
      ;;
    --all-agents)
      install_to "$HOME/.config/opencode/skills" "OpenCode (global)"
      install_to "$HOME/.agents/skills" "OpenCode (.agents global)"
      install_to "$HOME/.claude/skills" "Claude Code (global)"
      shift
      ;;
    --project-local)
      install_to "$SOURCE_DIR/.opencode/skills" "Project-local (.opencode)"
      install_to "$SOURCE_DIR/.claude/skills" "Project-local (.claude)"
      install_to "$SOURCE_DIR/.agents/skills" "Project-local (.agents)"
      shift
      ;;
    *)
      usage
      ;;
  esac
done

echo ""
echo "Synapse skills installed. Restart your agent to discover them."
