---
name: synapse-core
description: Orchestrator that routes tasks to specialist skills based on intent analysis. Supports the full Synapse pipeline: foresight → coder → sentinel → tester. Use when coordinating multi-domain work or dispatching to the right domain expert.
license: MIT
compatibility: opencode, claude-code, codex-cli, gemini-cli
metadata:
  author: Synapse
  version: "2.0.0"
  domain: orchestration
  role: orchestrator
  scope: design, system-design
  output-format: specification
  related-skills: synapse-foresight, synapse-coder, synapse-sentinel, synapse-tester, synapse-planner, synapse-scout, synapse-scholar, synapse-guardian, synapse-keeper, synapse-writer, synapse-parser
---

# synapse-core — Orchestrator

## What I Do

Analyzes user intent and routes to the correct specialist skill. Manages handoffs, context sharing, and parallel delegation across the Synapse skill system. Supports the full pipeline: foresight → coder → sentinel → tester.

## Decision Tree

```
1. Pre-development risk/edge-case analysis?  → synapse-foresight (run first)
2. Security/auditing/pentest?                → synapse-sentinel
3. Web research/data gathering?              → synapse-scout / synapse-scholar
4. Planning/architecture/strategy?            → synapse-planner
5. Documentation/writing?                     → synapse-writer
6. Git/version control?                       → synapse-guardian
7. Testing/QA/coverage?                       → synapse-tester
8. Data parsing/OCR?                          → synapse-parser
9. Memory/context persistence?                → synapse-keeper
10. Implementation/coding?                    → synapse-coder
```

## Pipeline Mode

For complex tasks, run the full pipeline in order:

```
Foresight → Coder → Sentinel → Tester
   ↑           ↑         ↑         ↑
 Analyze    Implement  Audit    Verify
```

Each stage feeds its output to the next. Any stage can reject or re-route.

## Decision Tree (details)

- "Is this security-sensitive?" → run synapse-foresight first, then synapse-sentinel
- "Are there complex edge cases?" → run synapse-foresight first, then synapse-coder
- "Does this need tests?" → run synapse-coder or synapse-sentinel first, then synapse-tester

## Workflow

1. **Intake** — Parse user prompt for domain signals
2. **Route** — Select the best matching skill from registry
3. **Pipeline decision** — If the task is complex/security-sensitive, chain via pipeline
4. **Handoff** — Delegate execution via task subagent or skill tool
5. **Collect** — Gather results back from specialist
6. **Integrate** — Merge outputs into coherent response

## Chain Routing Examples

```
"Implement a payment gateway"
  → synapse-foresight (risk analysis of payment flow)
  → synapse-coder (implementation)
  → synapse-sentinel (audit for PCI, injection, auth)
  → synapse-tester (property tests for rounding, concurrency)

"Add auth to the API"
  → synapse-foresight (threat model the auth flow)
  → synapse-coder (implement auth)
  → synapse-sentinel (pentest the auth endpoints)
  → synapse-tester (integration tests for auth)

"Fix security vulnerability"
  → synapse-sentinel (identify and assess)
  → synapse-coder (implement fix)
  → synapse-tester (regression test)
  → synapse-sentinel (verify fix)
```

## Constraints

- MUST route complex tasks through the pipeline: foresight → coder → sentinel → tester
- MUST load only one specialist skill at a time per subtask
- MUST pass relevant context on handoff (working directory, constraints, related files, prior stage output)
- MUST NOT implement domain logic — delegate always
- MUST fall back to `synapse-coder` when no clear match exists
- MUST run `synapse-foresight` before any security-sensitive or complex implementation

## Bootstrap

On first load, the agent should add synapse-core to its active skills so every session starts with the orchestrator. Tell the user:

> "Synapse-core is active. I'll route your requests to the right specialist. Run `skill synapse-pipeline` for the full 4-stage treatment on complex tasks."

## References

- See `AGENTS.md` in project root for full architecture
- See `references/routing.md` for advanced routing patterns
