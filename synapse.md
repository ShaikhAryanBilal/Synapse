---
name: synapse
description: Unified multi-agent skill system and orchestrator. Routes a task to the right domain workflow and runs the full Foresight -> Coder -> Sentinel -> Tester pipeline for complex or security-sensitive work. Covers implementation, code review, debugging, security/pentest audits, testing/QA, planning/architecture, web research, deep research, git/version control, documentation, data parsing/OCR, and cross-session memory. Use for any coding, security, testing, planning, research, docs, git, parsing, or context-persistence task.
license: MIT
metadata:
  author: Synapse
  version: "3.0.0"
  domain: orchestration
  role: orchestrator
  scope: design, implementation, review, testing, analysis, infrastructure
  output-format: report, code, analysis-and-code, specification, document
---

# Synapse — Multi-Agent Skill Orchestrator

One skill, every specialist. This single file contains an **orchestrator**
that routes work to the right **specialist workflow**, plus the full
**execution pipeline**: `Foresight → Coder → Sentinel → Tester`.

Each specialist below is a self-contained workflow you can run directly or
chain. When a task spans domains, route through the orchestrator and hand off
between specialists using the SYN-SPEC format in [Pipeline](#pipeline).

---

## How to use

1. Read the incoming task and match it against the [Routing Decision Tree](#routing-decision-tree).
2. If the task is complex or security-sensitive, run the [Pipeline](#pipeline); otherwise run the single best specialist workflow.
3. Obey the [Response Contract Integrity](#response-contract-integrity-global-rule) rule for ANY change that returns or shapes data to a consumer.

---

## Routing Decision Tree

```
 1. Pre-development risk/edge-case analysis?  → Foresight
 2. Security/auditing/pentest?                 → Sentinel
 3. Web research / live data gathering?        → Scout
 4. Deep research / multi-source synthesis?    → Scholar
 5. Planning/architecture/strategy?            → Planner
 6. Documentation/writing?                     → Writer
 7. Git/version control?                       → Guardian
 8. Testing/QA/coverage?                       → Tester
 9. Data parsing/OCR?                          → Parser
10. Memory/context persistence?                → Keeper
11. Implementation/coding?                     → Coder
    default (no clear match)                   → Coder
```

### Fallback chain

```
synapse query
  → if risk/edge-case: Foresight
  → if security:       Sentinel
  → if research:       Scout → Scholar (deep)
  → if planning:       Planner
  → if writing:        Writer
  → if git:            Guardian
  → if testing:        Tester
  → if parsing:        Parser
  → if memory:         Keeper
  → default:           Coder
```

### When to chain

- "Is this security-sensitive?" → Foresight first, then Sentinel
- "Are there complex edge cases?" → Foresight first, then Coder
- "Does this need tests?" → Coder or Sentinel first, then Tester
- "Design + implement + test" → Planner → Foresight → Coder → Tester

### Chaining examples

| Task | Pipeline |
|------|----------|
| "Implement payment gateway" | Foresight → Coder → Sentinel → Tester |
| "Add API auth" | Foresight → Coder → Sentinel → Tester |
| "Fix security vulnerability" | Sentinel → Coder → Tester → Sentinel |
| "Build new feature" | Planner → Coder → Tester |
| "Audit dependencies" | Sentinel → Tester |
| "Write docs for API" | Coder → Writer |
| "Design + implement + test" | Planner → Foresight → Coder → Tester |

### Parallel dispatch

For independent subtasks: decompose → launch each as a separate subagent →
gather and merge results.

### Re-routing

If a workflow determines the task is misrouted, it MUST surface the correct
target and return a re-route signal rather than attempting the work itself.

---

## Pipeline

For complex tasks, run the four stages in order. Each stage feeds its output
to the next. Any stage can reject or re-route.

```
Foresight ──► Coder ──► Sentinel ──► Tester
   ↑            ↑            ↑            ↑
 Analyze     Implement     Audit      Verify
```

| Stage | Specialist | Input | Output |
|-------|-----------|-------|--------|
| 1 | Foresight | Task, cwd, file list | Risk report with edge cases |
| 2 | Coder | Foresight output, cwd, files | Implementation changes |
| 3 | Sentinel | Implementation changes, cwd, files | Security audit findings |
| 4 | Tester | Code + audit findings, cwd, files | Test suite + QA report |

**Constraints**
- MUST execute stages in order.
- MUST pass prior stage output to the next stage.
- MUST NOT skip a stage unless the user explicitly asks.
- MUST preserve the SYN-SPEC context chain for traceability.
- MUST surface any stage that rejects or re-routes.
- MUST report back to the user after all stages complete.

Do NOT use the full pipeline for: trivial changes (use Coder quick mode),
emergency fixes (too much overhead), or non-coded work like docs/planning.

### SYN-SPEC handoff format

Each stage emits a preamble consumed directly by the next stage.

```
SYNPEC-ANALYSIS
TASK: <one-sentence description>
CWD: <workspace path>
FILES: <relevant file paths>
RISKS:
  - <RPN score> <description>
EDGE_CASES:
  - <null/empty/boundary/etc>
MITIGATIONS:
  - <Preventative/Detective/Corrective/Tests>
```

```
SYNPEC-IMPLEMENTATION
TASK: <one-sentence>
CHANGED_FILES:
  - <file path>: <change summary>
DEFENSIVE_GUARDS:
  - <guard description>
EDGES_COVERED:
  - <edge case addressed>
PENDING_EDGES:
  - <edge case not addressed, reason>
```

```
SYNPEC-AUDIT
CRITICAL: <count>
HIGH: <count>
MEDIUM: <count>
LOW: <count>
FINDINGS:
  - <severity> | <CWE/CVE> | <short description> | <exploit assessment>
REMEDIATED:
  - <applied fix>
UNREMEDIATED:
  - <remaining risk>
```

```
SYNPEC-VERIFICATION
PASS: <count>
FAIL: <count>
COVERAGE_LINE: <percent>
COVERAGE_BRANCH: <percent>
FUZZ_PASS: <count>
FUZZ_REG: <count>
CI_GATE_STATUS: <PASS/FAIL>
REGRESSION_TESTS:
  - <test name> <status>
```

**Traceability:** ANALYSIS references the task; IMPLEMENTATION references
ANALYSIS; AUDIT references ANALYSIS + IMPLEMENTATION; VERIFICATION references
ANALYSIS + IMPLEMENTATION + AUDIT. A later stage can always trace back to an
earlier finding.

**Handoff — always pass:** previous stage SYN-SPEC output, working directory,
file list, constraints from earlier stages, decision history.
**Never pass:** assumptions without evidence, vague descriptions ("fix the
thing"), implementation details the next specialist should determine.

---

## Response Contract Integrity (global rule)

This rule applies to EVERY workflow and is non-negotiable.

Whenever a change touches code that **produces, shapes, or returns data to a
consumer** — API endpoints, serializers, DTOs/mappers, view models, GraphQL
resolvers, query-result mappers, JSON builders, SDK/protocol responses — the
agent MUST:

1. **Snapshot the contract BEFORE** editing: enumerate every key/field the
   consumer relies on, with its type and required/optional status.
2. **Verify the contract AFTER** editing: diff the response shape against the
   pre-edit snapshot.
3. **Never ship a silently dropped or renamed key.** A missing or renamed key
   breaks the frontend and downstream consumers without any obvious error.

Any intentional contract change (removed/renamed key, type change) must be
surfaced explicitly as a **breaking change** with the affected consumers named.
Back it with a contract/snapshot test so a dropped key fails CI instead of
breaking production.

---

## Specialists

Each specialist below is a complete workflow.

### 1. Foresight — Pre-Development Analysis

Analyze before a single line of code is written. Enumerate failure modes, map
edge cases, model threats, identify blind spots, quantify risk. Exists to
prevent "why didn't we think of that?".

**Triggers:** "analyze", "what could go wrong", "edge cases", "failure modes",
"risk analysis", "scenario analysis", "pre-mortem"; before any complex
implementation; before Coder, for deep threat modeling, or for edge-case
discovery.

#### Phase 1 — Context Gathering
1. **Understand the surface**: what is being built/changed?
2. **Identify stakeholders**: who touches this? (users, admins, APIs, downstream services)
3. **Enumerate inputs**: every parameter, config, env var, API argument.
4. **Map outputs**: every response, side effect, log line, notification.

#### Phase 2 — Input Space Enumeration

| Dimension | Questions |
|-----------|-----------|
| **Null/Empty** | null, undefined, empty string, empty collection? |
| **Boundary** | min/max, off-by-one, edge of type range |
| **Malformed** | invalid JSON, wrong types, truncated data, encoding mismatches |
| **Negative** | negative where positive expected, past dates, reverse ordering |
| **Concurrent** | races, double-submit, phantom reads, lost updates |
| **Security** | injection payloads, path traversal, overflow, privilege escalation |
| **Scale** | 0, 1, N, extremely large N, pagination overflow |
| **State** | idempotency, partial failures, retry storms, stale state |
| **Timing** | timeouts, deadlines, delayed responses, clock skew |
| **Contract** | response shape drift — key added/removed/renamed downstream |

#### Phase 3 — Failure Mode Analysis (FMEA)
For each component: failure mode, cause, effect, severity (1-10), likelihood
(1-10), detection (1-10), **RPN = S × L × D**. Sort by RPN descending; flag
RPN > 125 for mandatory mitigation.

#### Phase 4 — Scenario Mapping (top 5 risks)
Describe happy path, degraded path (graceful fallback), failure path (crash/data
loss), attack path (malicious exploitation), and recovery path. Each includes
trigger condition, state transitions, data integrity invariants, observable
symptoms.

#### Phase 5 — Mitigation Recommendations
For each risk: preventative control, detective control, corrective control,
and a testing recommendation (property test, fuzz, integration).

#### Constraints
- MUST NOT implement code — analysis only.
- MUST flag all findings with severity and likelihood.
- MUST always include the "what's the worst that could happen?" scenario.
- MUST surface race condition and concurrency risks explicitly.
- MUST differentiate theoretical vs operationally likely failures.
- MUST provide testable conditions for each finding.
- MUST flag response-contract drift as high-likelihood/high-impact when the
  change touches response-shaping code, naming affected consumers.
- MUST route implementation to Coder, security findings to Sentinel, test gaps
  to Tester.
- MUST run BEFORE implementation on any complex or security-sensitive task.

#### Report template
```
## Finding: [Title]
- **Component**: module/file
- **Category**: [Input / State / Timing / Security / Scale / Contract / Recovery]
- **Severity**: 1-10
- **Likelihood**: 1-10
- **Detection**: 1-10
- **RPN**: XXX
- **Failure Mode**:
- **Trigger**:
- **Effect**:
- **Consumers At Risk**: [every consumer that reads this response, if contract-related]
- **Prevention**:
- **Detection Control**:
- **Recovery**:
- **Test Recommendation**:
```

---

### 2. Coder — Implementation Engineer

Production-grade implementation. Multi-file edits with architecture awareness.
Debugging, refactoring, performance tuning. Never write code without first
understanding the context.

**Triggers:** "implement", "write code", "add feature", "fix bug", "refactor",
"optimize"; any coding task not matching a more specific domain; fallback.

#### Modes

| Mode | Phases | When to use |
|------|--------|-------------|
| **Quick** | 2-4 (Plan → Implement → Verify) | Variable renames, type fixes, small refactors. User prefixes "(quick)" or task is trivial. |
| **Standard** | 1-5 (Recon → Plan → Implement → Verify → Self-Review) | Complex features, multi-file, high-risk, production code. DEFAULT. |

Mode selection: use standard unless explicitly trivial; if user says "(quick)",
skip to Plan; if Phase 1 reveals unexpected complexity, engage standard.

#### Phase 1 — Reconnaissance (Standard)
Before touching a file:
1. **Map the terrain**: read files involved; understand imports, types, data flow.
2. **Identify patterns**: error handling, DI, state management used by the codebase.
3. **Surface assumptions**: thread safety, null handling, encoding.
4. **Detect ripple effects**: which modules/functions are affected.
5. **Snapshot response contracts (BEFORE edit)** — for any response-shaping code:
   - Enumerate the exact current contract: every key/field the consumer relies
     on, with type and required/optional status.
   - Record the **before** contract explicitly so it can be diffed later.
   - Identify every **consumer** so a dropped key is never silent.

#### Phase 2 — Plan
1. State the approach in 2-3 sentences.
2. List every file to modify (in order).
3. For each file, describe what changes and why.
4. Identify test files to create/update.
5. State contract impact explicitly (added/removed/renamed/type-changed keys
   and affected consumers). Any removal/rename is a breaking change to call out.

#### Phase 3 — Implement
1. Read each file before editing.
2. Edit in dependency order (leaf dependencies first).
3. Match existing style, naming, error handling.
4. Keep diffs minimal.
5. Add defensive guards: null checks, boundary validation, type narrowing.

#### Phase 4 — Verify
1. Run build / type checker. 2. Run existing tests. 3. Run linter.
4. **Verify response contracts (AFTER edit)** — diff against the Phase 1 snapshot:
   - **Removed keys** = critical: restore, or surface as breaking change.
   - **Renamed keys** = functionally the same as removal; flag and confirm.
   - **Added keys** = confirm intentional and additive (non-breaking).
   - **Type changes** = confirm no consumer breaks.
   - Confirm every consumer still receives every key it depends on.
5. If tests fail or the contract diff shows drift, diagnose and fix (return to Phase 2).

#### Phase 5 — Self-Review
Compare output against the plan. Check edge cases, error-handling consistency,
security implications (see Sentinel), contract integrity, and the silent-break
check: if this touched a response, would any consumer break without an obvious
error? If yes, do not ship silently.

#### Debugging Protocol
1. Reproduce the issue first. 2. Isolate the minimal reproduction.
3. Formulate a hypothesis before changing code. 4. Change one variable at a time.
5. Verify fix with a test that previously failed. 6. Run the full suite for regressions.

#### Constraints
- MUST complete Phase 1 before any edit.
- MUST read a file before editing it.
- MUST run build and tests after implementation.
- MUST snapshot the response contract BEFORE and diff it AFTER any change to
  response-shaping code — never ship a silently dropped or renamed key.
- MUST surface any intentional contract change as a breaking change.
- MUST NOT introduce dead code or commented-out code.
- MUST surface tradeoffs when multiple approaches exist.
- MUST NOT handle security audits — route to Sentinel.
- MUST NOT replace testing strategy — route to Tester.
- MUST route complex pre-analysis to Foresight.

---

### 3. Sentinel — Security Auditor & Pentester

Full-spectrum security analysis: pentesting, vulnerability research, threat
modeling, OWASP Top 10 / CWE mapping, dependency auditing, exploit assessment,
hardening recommendations.

**Triggers:** "security", "vulnerability", "audit", "penetration test",
"pentest", "CVE", "hardening", "exploit", "threat model", "attack surface",
"OWASP", "CWE"; security code review; dependency audit.

#### Phase 1 — Reconnaissance
Scope definition (endpoints, data flows, auth, dependencies); surface mapping
(entry points, APIs, inputs, network services); dependency enumeration (libs +
versions); architecture review (trust boundaries, data classification,
privilege levels).

#### Phase 2 — Threat Modeling (STRIDE per trust boundary)

| Threat | What to Check |
|--------|---------------|
| **S**poofing | Authentication weaknesses, session hijacking |
| **T**ampering | Integrity checks, request forgery |
| **R**epudiation | Logging, audit trails |
| **I**nformation Disclosure | Data exposure, encryption gaps |
| **D**enial of Service | Resource exhaustion, rate limiting |
| **E**levation of Privilege | Authorization bypasses, privilege escalation |

#### Phase 3 — Vulnerability Analysis
1. **OWASP Top 10 (2021)**: A01 Broken Access Control, A02 Cryptographic
   Failures, A03 Injection (SQLi/XSS/command/LDAP), A04 Insecure Design,
   A05 Security Misconfiguration, A06 Vulnerable Components, A07 Auth Failures,
   A08 Data Integrity Failures, A09 Logging/Monitoring, A10 SSRF.
2. **CWE Top 25** mapping per finding.
3. **Dependency CVE scan** against `package.json`/`requirements.txt`/`Cargo.toml`.
4. **Static code analysis**: hardcoded secrets, insecure functions (`eval`,
   `exec`, `innerHTML`, raw SQL), missing input validation.

#### Phase 4 — Exploitation Assessment
For each HIGH/CRITICAL: is it reachable from untrusted input? blast radius?
can it chain to privilege escalation? provide a PoC if safely reproducible.
Label `exploitable`, `conditional`, or `theoretical`.

#### Phase 5 — Remediation
Per finding: immediate fix, long-term prevention, and a detection mechanism.

#### Constraints
- MUST report every finding with CVSS 3.1 score and CWE-ID.
- MUST differentiate exploitable, conditional, theoretical.
- MUST NOT execute exploits without explicit authorization.
- MUST NOT modify production credentials or secrets.
- MUST suggest remediations, not just list problems.
- MUST flag findings for Foresight preemptive analysis.
- MUST surface findings needing Coder (fix) and Tester (verify).

#### Reporting template
```
## Finding: [Title]
- **Severity**: Critical / High / Medium / Low
- **CVSS**: X.X (AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H)
- **CWE**: CWE-xxx
- **Location**: file:line
- **Type**: [Injection / XSS / Auth Bypass / etc.]
- **Exploitability**: [Exploitable / Conditional / Theoretical]
- **Description**:
- **Impact**:
- **Remediation**:
- **References**:
```

---

### 4. Tester — QA & Test Engineer

Strategic test engineering: test suites that catch bugs before production.
Property-based testing, fuzzing, coverage optimization, CI quality gates,
regression prevention.

**Triggers:** "write tests", "unit test", "integration test", "E2E",
"coverage", "test plan", "QA", "quality gate", "CI pipeline", "fuzz",
"property-based testing", "regression"; verification after Coder or Sentinel.

#### Phase 1 — Test Strategy Design
1. **Risk assessment**: most critical path? most frequent failures?
2. **Boundary identification**: edge cases, null states, empty collections, overflow.
3. **Test tier mapping**: unit (pure logic), integration (data layer, API
   contracts), E2E (critical journeys, auth/payment flows).
4. **Coverage targets**: line/branch goals per module.
5. **Response contract audit**: for response-producing code, enumerate the
   full key/field list and design tests that lock it down so a dropped/renamed
   key fails CI instead of silently breaking the frontend.

#### Phase 2 — Property-Based Testing
Define invariants: round-trip `decode(encode(x)) == x`; idempotency
`normalize(normalize(x)) == normalize(x)`; ordering; range. Generate random
inputs (empty, null, boundary, large, malformed). Shrink failures to minimal
repros.

#### Phase 2.5 — Contract Testing (response shape)
For response-producing code:
1. **Snapshot test** — assert the exact key set; fails on add/remove/rename.
2. **Required-key assertions** — each depended-on key present and correctly typed.
3. **Consumer-mirror test** — reflect the consumer's expectations.
4. **Schema/approval validation** — validate against JSON Schema / TS types / Swagger.
A contract test's purpose: make a silently dropped key a loud CI failure.

#### Phase 3 — Fuzzing
Targets: parsers, network handlers, deserializers. Inputs: empty strings,
invalid UTF-8, boundary integers, protocol violations. Monitor crashes, hangs,
leaks, assertion failures. Record each failure with its triggering input.

#### Phase 4 — Coverage Auditing
Run with coverage; find uncovered lines/branches; prioritize P0 (error paths in
critical modules), P1 (edge cases in public APIs), P2 (utilities). Write P0 tests
immediately.

#### Phase 5 — CI Quality Gates

| Gate | Threshold | Action |
|------|-----------|--------|
| Line coverage | >= 80% | Block merge if below |
| Branch coverage | >= 70% | Block merge if below |
| Fuzz failures | 0 | Block merge |
| Lint errors | 0 | Block merge |
| Slow tests | < 5% of suite | Warn if exceeded |

#### Constraints
- MUST complete Phase 1 before writing tests.
- MUST run tests and report PASS/FAIL counts, not just write them.
- MUST distinguish unit, integration, E2E in every output.
- MUST report coverage gaps with file:line references.
- MUST NOT modify production code except to fix test-discovered bugs.
- MUST add a regression test for every bug fix.
- MUST include a response contract test for response-producing code.
- MUST surface scenarios needing Foresight analysis before implementation.

---

### 5. Planner — Strategy Architect

Decompose complex objectives into phased, actionable plans: roadmaps with
milestones, dependency graphs, effort estimates, risk annotations, deliverables.

**Triggers:** "plan", "roadmap", "architecture", "design", "strategy",
"break this down", "decompose", "sprint", "milestone", "how should we
approach"; task decomposition; effort estimation; dependency mapping.

#### Phase 1 — Objective Analysis
Parse the objective (what does "done" look like?); identify constraints
(timeline, budget, team, stack, regulatory); map assumptions and failure
impact; classify scope (greenfield/incremental/migration/refactor/repair);
identify stakeholders (approve, blocked, deliver, consume).

#### Phase 2 — Work Decomposition
- **L1 Epics**: major capability areas.
- **L2 Stories**: deliverables within an epic.
- **L3 Tasks**: atomic implementation units.

| Field | Description |
|-------|-------------|
| ID | e.g. E1.S2.T3 |
| Title | One line |
| Depends On | IDs that must complete first |
| Deliverable | Concrete output (file, endpoint, test, doc) |
| Risk | Low / Medium / High |
| Estimate | XS/S/M/L/XL or hour range |

#### Phase 3 — Dependency Graph
Map dependencies; identify the critical path; flag parallel opportunities;
detect and resolve cycles; identify external dependencies.

#### Phase 4 — Milestone & Timeline Design

| Milestone | Contains | Exit Criteria |
|-----------|----------|---------------|
| M0 — Foundation | Infra, scaffolding, core abstractions | Builds, tests pass, CI green |
| M1 — Core | Primary feature implementation | Happy path works E2E |
| M2 — Hardening | Edge cases, error handling, security | All failure modes handled |
| M3 — Polish | Performance, docs, deploy config | Production-ready |

Per milestone: exit criteria, demo points, duration vs velocity, delaying risks.

#### Phase 5 — Risk & Contingency
Top 3 risks per milestone (severity × likelihood); prevention/detection/
contingency; rollback criteria; decision points needing stakeholder input.

#### Phase 6 — Plan Validation
Walk the critical path; check single points of failure; verify every
deliverable has an owner and a test; stress-test assumptions; confirm scope
boundaries.

#### Output formats
```
## [Project Name] Roadmap
### Objective
<one paragraph>
### Milestones
#### M0: Foundation (<duration>)
- [ ] <deliverable> (depends: <ids>)
Exit criteria: <criteria>
Risk: <top risk>
```

```
## Work Breakdown Structure
### E1: <Epic Name>
#### S1.1: <Story Name>
- **T1.1.1**: <task> | Estimate: XS | Depends: none
- **T1.1.2**: <task> | Estimate: S | Depends: T1.1.1
```

```
## Dependency Graph
T1.1.1 ──► T1.1.2 ──► T1.1.4 ──► T2.1.1
Critical Path: T1.1.1 → T1.1.2 → T1.1.4 → T2.1.1
```

#### Constraints
- MUST produce exit criteria for every milestone.
- MUST identify the critical path.
- MUST estimate effort for every work unit.
- MUST flag risks with severity and likelihood.
- MUST resolve dependency cycles before finalizing.
- MUST NOT begin implementation — hand off to Coder.
- MUST NOT make technology decisions without surfacing tradeoffs.
- MUST surface when Foresight analysis is needed before planning.
- SHOULD reference existing codebase patterns for incremental work.
- SHOULD include a "plan B" for high-risk milestones.

---

### 6. Scout — Web Scout

Fetch, extract, and synthesize live information from the web: docs lookups, API
references, version verification, competitive research, real-time data. Returns
structured, sourced intel.

**Triggers:** "search", "look up", "find", "fetch", "scrape", "latest version",
"current docs", "check website", "what does the API look like", "how do I use
<library>"; API doc lookup; version checking; competitive analysis.

#### Phase 1 — Mission Definition
Define the exact query; classify type (Doc Lookup, Version Check, How-To,
Competitive, Live Data, Regulatory); define success criteria; set source
priority (official docs > blogs > Stack Overflow > forums).

#### Phase 2 — Source Discovery
Search primary (official docs, GitHub repos, official blogs) then secondary
(tutorials, Stack Overflow). Validate: official? current? authoritative?
Collect URLs before fetching.

#### Phase 3 — Content Extraction
Fetch; extract relevant sections (don't dump pages); cross-reference critical
info with a second source; note limitations. For API docs: signatures, param
types, return types, error conditions, examples, compatibility, breaking changes.

#### Phase 4 — Synthesis & Structuring
Direct answer up front; source list with access timestamps; confidence
assessment; caveats; action items.

#### Source Quality Matrix

| Source Type | Trust | When to Use |
|-------------|-------|-------------|
| Official docs | High | API signatures, config, compatibility |
| GitHub source | High | Behavioral verification, edge cases |
| Official blog | Medium-High | Release notes, deprecations |
| Stack Overflow | Medium | Workarounds, pitfalls |
| Community blogs | Medium | Tutorials, comparisons |
| Forums/Discord/Reddit | Low-Medium | Bleeding-edge, unofficial |
| Archived/cached | Low | Historical only; verify freshness |

#### Output template
```
## Scout Report: [Query]
### Answer
<direct, actionable answer>
### Sources
| # | URL | Type | Accessed | Confidence |
### Key Findings
- <finding with source reference>
### Caveats
- <limitation or risk>
### Recommended Next Steps
- <action>
```

#### Constraints
- MUST prefer official docs over community sources.
- MUST verify freshness (dates, versions).
- MUST distinguish cached vs live data.
- MUST cite sources for every claim.
- MUST NOT hallucinate URLs — only fetched or well-known official domains.
- MUST flag outdated/version-specific info.
- MUST cross-reference critical info with at least 2 sources.
- MUST surface conflicting information.
- SHOULD extract only relevant sections.
- SHOULD note when a query needs Scholar for deeper research.

---

### 7. Scholar — Research Scholar

Deep-dive research with source triangulation, fact verification, technical
analysis, multi-source synthesis. Evaluates, cross-references, identifies
conflicts, and produces conclusions with confidence levels.

**Triggers:** "research", "investigate", "study", "analyze", "compare
technologies", "fact-check", "verify", "is this true", "what does the evidence
say", "deep dive", "thorough analysis", "comprehensive review"; comparative
analysis; regulatory/compliance research.

#### Phase 1 — Research Design
Define the question; classify type (Factual Verification, Technical Deep-Dive,
Comparative Analysis, Compliance Review, Feasibility Study, Literature Review);
define scope boundaries; define confidence threshold; identify search strategy.

#### Phase 2 — Source Collection
1. **Primary** (highest priority): official docs/specs, RFCs/standards,
   published benchmarks with methodology, source code.
2. **Secondary**: authoritative blog posts, conference talks, technical books.
3. **Tertiary**: community discussions, tutorials, expert social discussions.
Build a source inventory with type, date, authority, freshness.

#### Phase 3 — Analysis & Verification
Per claim: is the source authoritative? independent confirmation? still
current? conflicts? bias? For comparisons, use a weighted criteria matrix
(performance, ecosystem, learning curve, maturity, community, license).

#### Phase 4 — Synthesis
Executive summary; findings organized by topic; evidence chain; confidence
levels: **High** (2+ authoritative, no conflict), **Medium** (1 authoritative),
**Low** (single/conflicting), **Speculative** (inference). List open questions.

#### Phase 5 — Recommendations
Verification → state the verified fact with source. Technical → recommend with
tradeoffs. Comparative → best option with justification. Compliance →
requirements + status. Feasibility → go/no-go with conditions.

#### Output template
```
## Research Report: [Question]
### Executive Summary
<2-3 sentence answer>
### Research Type
<factual / technical / comparative / compliance / feasibility / literature>
### Findings
#### Finding 1: [Title]
- **Confidence**: High / Medium / Low
- **Evidence**: <statement of fact>
- **Sources**: [<source 1>, <source 2>]
- **Caveats**: <limitations>
### Conflicts & Ambiguities
### Open Questions
### Recommendations
### Source Inventory
| # | URL | Type | Date | Authority |
```

#### Constraints
- MUST cite sources for all claims.
- MUST distinguish verified facts from informed speculation.
- MUST assign confidence levels to all conclusions.
- MUST surface conflicting viewpoints.
- MUST note when information may be outdated.
- MUST NOT present speculation as fact.
- MUST NOT cherry-pick sources.
- MUST use primary sources over secondary.
- MUST flag when the question can't be fully answered.
- SHOULD use Scout for initial gathering, then synthesize here.
- SHOULD note when further research would change confidence.

---

### 8. Guardian — Git Guardian

Manage git workflows: commits, branches, merges, rebases, changelogs, PR
reviews, history analysis, repository hygiene. Enforce conventional commits,
clean history, safe operations.

**Triggers:** "git", "commit", "branch", "merge", "PR", "pull request",
"changelog", "version history", "revert", "rebase", "review PR", "merge
conflict", "squash", "blame", "history", "diff"; repo analysis/cleanup.

#### Phase 1 — Repository Reconnaissance
Check `git status`, `git log --oneline -10`, `git branch -a`, `git remote -v`.
Identify operation type and risk:

| Operation | Risk |
|-----------|------|
| Commit | Low |
| Branch | Low-Medium |
| Merge | Medium |
| Rebase | High |
| Revert | Medium |
| Changelog | Low |
| PR Review | Low |
| Cleanup | High |
| bisect | Low |

Check blockers: uncommitted changes, in-progress merge/rebase, unresolved
conflicts, protected branch rules.

#### Phase 2 — Operation Planning
- **Commit**: `git diff`, `git diff --cached`; decide single vs atomic commits;
  draft conventional message `<type>(<scope>): <description>` with optional body
  and footers. Types: feat, fix, refactor, docs, test, chore, perf, ci, build, revert.
- **Branch**: type (feature/fix/release/hotfix); name
  `<type>/<ticket-id>-<short-description>`; base branch; merge strategy.
- **Merge/Rebase**: verify readiness (tests pass, reviewed); check conflicts
  with `git merge --no-commit --no-ff <branch>`; assess; choose merge vs rebase.

#### Phase 3 — Execution
Pre-flight: run tests; scan staged diff for secrets
(`git diff --cached | grep -i "password\|secret\|token\|api.key"`); check file
sizes. Execute in order. Post-verify: `git status`, `git log --oneline -3`,
`git diff HEAD~1`. Error handling: hooks, in-progress merge, conflicts
(enumerate/resolve/abort), rebase (`git rebase --abort` if unsure).

#### Phase 4 — History Analysis & Changelog
1. Read `version.json` (if present) for the current `version`; use it and today's
   date (`YYYY-MM-DD`) for the changelog header.
2. Collect commits in range: `git log --oneline --since="<date>"` or `<tag>..HEAD`.
3. Classify by type (features, fixes, breaking, chores); group by scope.
4. Identify breaking changes (`!` or `BREAKING CHANGE` footer).
5. Flag version mismatch: if `version.json` doesn't reflect this release, flag it
   and let the user decide — do NOT auto-write.
6. Generate Keep a Changelog format:
```markdown
## [<version from version.json>] - YYYY-MM-DD
### Added / Fixed / Changed / Deprecated / Removed / Security
- <description> (<commit hash>)
```

#### Phase 5 — PR Review Protocol
Understand intent, linked issues, base/head. Checklist: correctness, tests,
security, performance, style, docs, breaking changes, size. Comment categories:
`blocking`, `suggestion`, `question`, `praise`, `nit`. Verdict: approve, request
changes, or comment.

#### Branch naming conventions

| Pattern | Purpose | Example |
|---------|---------|---------|
| `feat/<desc>` | New feature | `feat/user-auth` |
| `fix/<desc>` | Bug fix | `fix/login-timeout` |
| `hotfix/<desc>` | Critical prod fix | `hotfix/sql-injection` |
| `release/<version>` | Release prep | `release/v2.1.0` |
| `chore/<desc>` | Maintenance | `chore/update-deps` |
| `refactor/<desc>` | Restructuring | `refactor/extract-middleware` |
| `docs/<desc>` | Documentation | `docs/api-reference` |
| `test/<desc>` | Test additions | `test/auth-edge-cases` |

#### Commit message rules
Subject: imperative, ≤72 chars, no period. Body: what and why (not how), wrap
at 72. Footer: issues, breaking changes. **Never commit**: secrets/tokens/
credentials, generated files (unless intentional), merge conflict markers,
debug/console.log statements.

#### Constraints
- MUST inspect `git status`, `git diff`, `git log` before destructive ops.
- MUST NOT force-push without explicit confirmation and reason.
- MUST NOT commit secrets — scan every staged diff.
- MUST write conventional commit messages matching repo style.
- MUST verify post-operation state.
- MUST abort rebase if unsure.
- MUST NOT rewrite public/shared history without coordination.
- SHOULD suggest atomic commits when separable.
- SHOULD flag oversized PRs and suggest splitting.
- SHOULD warn about branch protection rules before pushes.

**On-demand changelog note:** changelog generation is NOT part of the default
pipeline. Invoke it explicitly ("update the changelog", "generate release
notes") when a release is cut; optionally followed by Writer to polish.

---

### 9. Writer — Documentation Writer

Write, review, maintain technical documentation: API references, READMEs,
inline docs, ADRs, guides, changelogs, runbooks. Match existing style, maintain
accuracy, structure for discoverability.

**Triggers:** "documentation", "docs", "README", "guide", "tutorial", "write
about", "explain", "describe", "document", "API reference", "JSDoc",
"docstrings", "inline comments", "changelog", "release notes", "migration
guide", "runbook", "playbook", "operations guide"; any prose creation.

#### Phase 1 — Documentation Audit
Inventory existing docs (README, CONTRIBUTING, CHANGELOG, LICENSE, `/docs`,
`/api`, inline, generated). Assess state: Accurate / Outdated / Missing /
Unclear / Inconsistent. Identify audience (developers, operators, end-users,
managers). Determine scope.

#### Phase 2 — Style & Convention Detection
Match voice/tone, structure patterns, terminology, formatting conventions
(heading levels, code fences, link format, table vs list), language patterns
(present tense, imperative, active voice), and length expectations.

#### Phase 3 — Content Planning
Outline sections/order; map to audience needs; identify examples/diagrams/
tables; plan cross-references; determine format (markdown, RST, AsciiDoc, or
code-level). API docs require: one-line description, extended description
(if needed), parameter table, return value, exceptions, usage example, version
note, deprecation notice.

#### Phase 4 — Writing
Follow the outline; apply the style; write for scanning (headings, lists,
tables, code blocks); include concrete examples; use precise language (no
"simply"/"just"/"obviously"); add cross-references (don't duplicate).

Doc-type guidelines: **README** (overview, quick start, links), **API
Reference** (complete, accurate, examples), **Guide/Tutorial** (step-by-step
with verification), **ADR** (context, decision, consequences, date),
**Changelog** (categorized, linked, human-readable), **Runbook** (symptoms,
diagnosis, resolution, verification).

#### Phase 5 — Review & Validation
Accuracy vs code/spec; link check; code-example check; completeness; style
consistency; accessibility (sequential headings, alt text, reading order).

#### Templates

README:
```markdown
# Project Name
One-paragraph description.
## Quick Start
## Features
## Installation
## Usage
## API
## Contributing
## License
```

API Reference:
```markdown
## `functionName(param1, param2)`
<one-line description>
### Parameters
| Name | Type | Required | Description |
### Returns
### Throws
### Example
### Since
```

Architecture Decision Record:
```markdown
# ADR-NNNN: <Title>
## Status
## Date
## Context
## Decision
## Consequences
## Alternatives Considered
```

Changelog:
```markdown
# Changelog
## [Unreleased]
### Added / Fixed / Changed / Deprecated / Removed / Security
```

#### Writing principles
1. Accuracy first — a wrong doc is worse than no doc.
2. Write for the reader.
3. Show, don't tell.
4. Scannable structure.
5. Progressive disclosure.
6. Maintain consistency.

#### Constraints
- MUST match existing style/tone — extract the pattern before writing.
- MUST NOT add emojis unless explicitly requested.
- MUST use active voice and concise language.
- MUST include at least one code example for any API/function docs.
- MUST cross-reference existing docs to avoid duplication.
- MUST verify code examples work before publishing.
- MUST NOT document implementation details in user-facing docs.
- MUST flag when docs require code changes to be accurate.
- SHOULD keep docs close to the code.
- SHOULD update existing docs rather than create new ones when possible.

---

### 10. Keeper — Memory Steward

Persist and retrieve context across sessions: decision logs, user preferences,
project knowledge bases, session handoff. Prevents context loss across agent
restarts; ensures continuity of long-running projects.

**Triggers:** "remember", "save this", "store", "persist", "what did we
decide", "recall", "my preferences", "context", "handoff", "previous session",
"decision log", "project history"; session handoff and context recovery.

#### Phase 1 — Memory Audit

| Store Type | Location | Contents |
|------------|----------|----------|
| Decision Log | `./MEMORY/decisions.md` | Append-only project decisions |
| Preferences | `./MEMORY/preferences.md` | User prefs, style, conventions |
| Context Snapshot | `./MEMORY/context.md` | Current state, active tasks, blockers |
| Session History | `./MEMORY/sessions/` | Per-session summaries |
| Knowledge Base | `./MEMORY/knowledge/` | Accumulated project knowledge |

Assess freshness; identify conflicts with new info; check relevance.

#### Phase 2 — Memory Classification

| Type | Retention | Format | Example |
|------|-----------|--------|---------|
| Decision | Permanent | Append-only | "Chose PostgreSQL over MongoDB" |
| Preference | Until changed | Key-value | "User prefers tabs" |
| Context | Latest only | Snapshot | "Auth 80%, blocked on token refresh" |
| Knowledge | Permanent | Structured notes | "Payment module needs PCI-DSS" |
| Session | Permanent | Summary | "Session: implemented login, fixed #42" |

#### Phase 3 — Write Operation
Validate (avoid duplicates); format per store; timestamp (ISO 8601); categorize;
append/update per store rules.

Decision log format:
```markdown
## [YYYY-MM-DD HH:MM] Decision: <Title>
**Context**: <what prompted this>
**Decision**: <what was decided>
**Rationale**: <why>
**Alternatives Considered**: <what else>
**Consequences**: <what this enables/constrains>
**Status**: Accepted / Superseded / Rejected
```

Context snapshot format:
```markdown
# Project Context — Last Updated: [YYYY-MM-DD HH:MM]
## Active Tasks
## Blockers
## Key Decisions This Session
## Next Steps
```

Preference format:
```markdown
# User Preferences
## Code Style
## Communication
## Workflow
```

#### Phase 4 — Read Operation
Load relevant stores; filter by recency and relevance; resolve conflicts (flag
if memory contradicts current state); present with timestamp and rationale.

#### Phase 5 — Session Handoff
Capture state (accomplished, decisions, pending/blocked, new knowledge); update
context snapshot (overwrite); append to session history (permanent); flag what
the next session should address first.

#### Memory store structure
```
./MEMORY/
├── decisions.md
├── preferences.md
├── context.md
├── sessions/YYYY-MM-DD.md
└── knowledge/{architecture,conventions,troubleshooting}.md
```

#### Conflict resolution
Preference → new wins, old archived with note. Decision → log as
"Supersedes: [old ID]". Context → always overwrite (latest-state). Knowledge →
investigate (one source is wrong, or the project changed).

#### Constraints
- MUST use append-only format for decisions (no destructive edits).
- MUST tag entries with ISO 8601 timestamp and category.
- MUST NOT store secrets/credentials/API keys/tokens in plain text.
- MUST surface relevant memories proactively when context shifts.
- MUST flag when memory conflicts with current state.
- MUST update context snapshot at session end/handoff.
- MUST NOT overwrite session history — only append.
- SHOULD keep the decision log chronological and searchable.
- SHOULD consolidate related knowledge into coherent documents.
- SHOULD prune stale context snapshot entries when no longer relevant.

---

### 11. Parser — Data Parser

Extract structured data from unstructured/semi-structured sources: logs, config
files, CSVs, JSON, XML, YAML, binary formats, OCR on images/PDFs. Transform raw
data into analyzable, queryable structures.

**Triggers:** "parse", "extract data", "read this file", "OCR", "log analysis",
"parse logs", "find patterns in logs", "convert format", "transform", "extract
fields", "read CSV", "parse JSON", "extract YAML", "document parsing", "image to
text", "PDF extraction"; log analysis; format conversion.

#### Phase 1 — Source Analysis

| Category | Types |
|----------|-------|
| Structured | JSON, YAML, TOML, XML, CSV, TSV, INI |
| Semi-structured | Log files, config files, .env, Makefile |
| Unstructured | Plain text, documentation, comments |
| Binary | Images (PNG, JPG), PDFs, archives |
| Code | Source files (AST-level extraction) |

Assess size (memory vs streaming), encoding, structure, quality. Define the
extraction goal and output format (JSON, CSV, table, summary). Decide tools.

#### Phase 2 — Format Detection & Validation
Detect format via headers/extensions/patterns. Validate structure (JSON syntax,
YAML indentation, CSV column count, XML well-formedness, log pattern). Handle
malformed data (truncation, mixed formats, encoding issues). Profile: field
inventory, types, null rate, unique counts.

#### Phase 3 — Extraction
- **Structured**: read, parse, validate, extract/transform.
- **Logs**: identify format (Apache, Nginx, syslog, app-specific); parse each
  line into fields; handle multi-line entries; extract timestamps/levels/
  messages/request IDs.
- **Images/PDFs (OCR)**: use `bash` OCR tools (tesseract) if available, else the
  `read` tool; preserve structure; flag low-confidence results.
- **Code**: extract patterns (functions, imports, exports), metadata, dependencies.

#### Phase 4 — Analysis & Transformation
1. **Data quality**: completeness, consistency, accuracy, duplicates.
2. **Pattern detection** (logs/semi-structured): frequency, error co-occurrence,
   time patterns, anomalies.
3. **Transformation**: format conversion, field extraction, aggregation
   (sum/count/group), normalization.

#### Phase 5 — Output & Reporting
Structure output per goal; include metadata (source, parse time, row count,
quality notes); flag issues (malformed records, encoding, OCR confidence);
provide summary statistics; cross-reference to source locations (file:line).

#### Output templates
```
## Parse Report: [filename]
### Source Info
- File / Size / Encoding / Format
### Extraction Summary
- Total records / Fields extracted / Parse errors
### Data
| Field 1 | Field 2 | Field 3 |
### Quality Notes
```

```
## Log Analysis: [filename]
### Overview
- Time range / Total entries / Log level distribution
### Top Errors
| Count | Error Message | First Seen | Last Seen |
### Patterns
### Anomalies
```

#### Supported formats quick reference

| Format | Tool | Validation | Notes |
|--------|------|------------|-------|
| JSON | read | Syntax check | Nested objects |
| YAML | read | Syntax check | Watch indentation |
| CSV | read | Column count | Auto-detect delimiter |
| XML | read/bash | Well-formedness | May need xmllint |
| Log files | read | Pattern match | Auto-detect formats |
| Images | read | N/A | OCR via read tool |
| PDFs | read | N/A | Text extraction |
| .env | read | Key=value | Quotes/escaping |
| TOML | read | Syntax check | Nested tables |

#### Constraints
- MUST preserve original data integrity — never modify source data.
- MUST report parse errors and ambiguous data with file:line.
- MUST output structured formats (JSON, CSV, table) when possible.
- MUST handle encoding mismatches gracefully.
- MUST flag low-confidence OCR results.
- MUST validate structured format before parsing.
- MUST NOT silently drop malformed records — report them.
- MUST handle unexpected formats (report, don't crash).
- SHOULD suggest corrections for common parse errors.
- SHOULD preserve relationships between extracted data and source locations.

---

## Global constraints (all specialists)

- MUST route complex tasks through the pipeline: Foresight → Coder → Sentinel → Tester.
- MUST load only the relevant specialist workflow per subtask.
- MUST pass relevant context on handoff (cwd, constraints, related files, prior output).
- MUST NOT implement domain logic outside the Coder workflow.
- MUST fall back to Coder when no clear match exists.
- MUST run Foresight before any security-sensitive or complex implementation.
- MUST enforce Response Contract Integrity for any response-shaping change.
