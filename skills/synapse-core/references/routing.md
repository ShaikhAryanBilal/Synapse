# Advanced Routing Patterns

## Pipeline Execution

For complex tasks, skills execute in order:

```
Foresight ──► Coder ──► Sentinel ──► Tester
  │            │            │            │
 Analyze    Implement    Audit       Verify
```

Each stage feeds its output to the next. Any stage can reject or re-route.

## Pipeline Examples

| Task | Pipeline |
|------|----------|
| "Implement payment gateway" | foresight → coder → sentinel → tester |
| "Add API auth" | foresight → coder → sentinel → tester |
| "Fix security vulnerability" | sentinel → coder → tester → sentinel |
| "Build new feature" | planner → coder → tester |
| "Audit dependencies" | sentinel → tester |
| "Write docs for API" | coder → writer |
| "Design + implement + test" | planner → foresight → coder → tester |

## Multi-Skill Chains

When a task spans multiple domains, chain skills sequentially:

```
User: "Design auth, analyze risks, implement, audit, and test it"
Route: synapse-planner → synapse-foresight → synapse-coder → synapse-sentinel → synapse-tester
```

```
User: "Implement and write tests"
Route: synapse-coder → synapse-tester
```

## Parallel Dispatch

For independent subtasks, delegate in parallel:

1. Analyze intent and decompose into independent subtasks
2. Launch each subtask as a separate task subagent
3. Gather results and merge

## Fallback Chain

```
synapse-core query
  → if risk/edge-case: synapse-foresight
  → if security:       synapse-sentinel
  → if research:       synapse-scout → synapse-scholar (deep)
  → if planning:       synapse-planner
  → if writing:        synapse-writer
  → if git:            synapse-guardian
  → if testing:        synapse-tester
  → if parsing:        synapse-parser
  → if memory:         synapse-keeper
  → default:           synapse-coder
```

## On-Demand Release & Changelog (not in the default pipeline)

Changelog generation is intentionally NOT part of the standard
`foresight → coder → sentinel → tester` pipeline — it would add overhead to
every task. It is a manual, on-demand flow routed to guardian only when asked:

```
User: "update the changelog for this release"
  → synapse-guardian (Phase 4: reads version.json, classifies commits,
       generates Keep-a-Changelog entry, flags version drift)
  → optionally synapse-writer (polish/review the entry)
```

Invoke it explicitly (e.g. "update the changelog", "generate release notes")
when a release is cut. Everyday coding tasks stay on the fast path.

## Context Passing on Handoff

When delegating, always include:

| Field | Description |
|-------|-------------|
| `task` | Clear one-sentence definition |
| `cwd` | Working directory |
| `files` | Relevant file paths (if any) |
| `constraints` | Architecture decisions, style rules, prior stage findings |
| `output_format` | Expected result structure |
| `prior_analysis` | Output from previous pipeline stage (if any) |
| `max_iterations` | Optional iteration limit |

## Re-Routing

If a specialist skill determines the task is misrouted, it MUST surface the correct target and return a re-route signal rather than attempting the work itself.
