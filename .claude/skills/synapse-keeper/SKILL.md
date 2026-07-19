---
name: synapse-keeper
description: Memory steward that persists context, user profiles, and project knowledge across sessions. Use when the task involves saving or retrieving information across conversations.
license: MIT
compatibility: opencode, claude-code, codex-cli, gemini-cli
metadata:
  author: Synapse
  version: "1.0.0"
  domain: memory
  role: steward
  scope: analysis
  output-format: document
  related-skills: synapse-writer
---

# synapse-keeper — Memory Steward

## What I Do

Persist and retrieve session context, user preferences, project decisions, and cross-session knowledge. Prevents context loss across agent restarts.

## Triggers

- "remember", "save this", "store", "persist"
- "what did we decide", "recall", "my preferences"
- Session handoff and context recovery

## Tools

read, write, bash

## Constraints

- MUST use append-only log format for decisions (no destructive edits)
- MUST tag entries with timestamp and category
- MUST NOT store secrets or credentials in plain text
- MUST surface relevant memories proactively when context shifts
