---
name: synapse-pipeline
description: End-to-end execution pipeline that coordinates Foresight, Coder, Sentinel, and Tester in a single orchestrated pass. Load this skill when you have a complex or sensitive task that needs the full treatment. Single prompt, four specialist skills.
license: MIT
compatibility: opencode, claude-code, codex-cli, gemini-cli
metadata:
  author: Synapse
  version: "1.0.0"
  domain: orchestration
  role: orchestrator
  scope: design, system-design, analysis
  output-format: report, code, analysis-and-code
  related-skills: synapse-foresight, synapse-coder, synapse-sentinel, synapse-tester
---

# synapse-pipeline — Four-Stage Execution Pipeline

## What I Do

Load this single skill, and the four Synapse specialist skills execute in order:
**Foresight → Coder → Sentinel → Tester**.

I handle context preservation, cross-stage dependency injection, and result formatting. You do one prompt, I do four passes.

## Triggers

Use this skill when you want to:
- Build something new and ensure it's done right
- Tackle a feature with security, quality, and correctness concerns
- Avoid the cost of missed edge cases and late-stage security bugs

Do NOT use this skill for:
- Simple, straightforward changes (use synapse-coder's quick mode)
- Emergency fixes (too much overhead)
- Non-coded work like documentation or planning

## Execution Order

### Stage 1 — synapse-foresight (Analyze)
Loads the foresight skill, performs:
- Context gathering
- Input space enumeration (9 dimensions)
- Failure mode analysis (FMEA)
- Scenario mapping

Output: risk report with prioritized findings.

### Stage 2 — synapse-coder (Implement)
Loads the coder skill with the foresight output as prior analysis:
- Reconnaissance enriched by foresight findings
- Plan incorporates risk mitigations
- Implementation adds defensive guards for every high RPN item
- Self-review checks each foresight edge case

Output: implemented code changes.

### Stage 3 — synapse-sentinel (Audit)
Loads the sentinel skill with the implemented code:
- Reconnaissance on the new code
- Threat modeling for introduced attack surface
- Vulnerability scan on fresh code
- Dependency audit for any new libraries
- Remediation for discovered findings

Important: Every sentinel finding must be labeled with severity to inform the tester phase.

Output: security audit report.

### Stage 4 — synapse-tester (Verify)
Loads the tester skill with both the code and the sentinel findings:
- Test strategy incorporating the foresight edge cases
- Property tests for any risky functions
- Fuzz tests for all inputs enumerated in stage 1
- Coverage audit to ensure sentinel's remediations are tested
- CI gate enforcement

Output: test suite + QA pass/fail.

## Stage Output Format

Each stage must produce a SYN-SPEC formatted document for the next stage. The format is defined in the pipeline context reference.

### Stage 1 output: SYNPEC-ANALYSIS
### Stage 2 output: SYNPEC-IMPLEMENTATION
### Stage 3 output: SYNPEC-AUDIT
### Stage 4 output: SYNPEC-VERIFICATION

## Quick Reference

| Stage | Skill | Input | Output |
|-------|-------|-------|--------|
| 1 | Foresight | Task description, cwd, file list | Risk report with edge cases |
| 2 | Coder | Foresight output, cwd, file list | Implementation changes |
| 3 | Sentinel | Implementation changes, cwd, file list | Security audit findings |
| 4 | Tester | Code + audit findings, cwd, file list | Test suite + QA report |

## Constraints

- MUST execute stages in order
- MUST pass prior stage output to next stage
- MUST NOT skip a stage unless explicitly told by the user
- MUST preserve the SYN-SPEC context chain for traceability
- MUST surface any stage that rejects or re-routes
- MUST report back to the user after all stages complete

## See also

- pipeline-references/handoff.md for SYN-SPEC format
- pipeline-references/chain-templates.md
