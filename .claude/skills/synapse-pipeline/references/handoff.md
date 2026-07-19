# SYN-SPEC: Pipeline Stage Context Format

Each stage produces a preamble that feeds directly to the next stage. Use this format exactly.

## SYNPEC-ANALYSIS (Stage 1 output)

```
SYNPEC-ANALYSIS
TASK: <one-sentence description>
CWD: <workspace path>
FILES: <relevant file paths>
RISKS:
  - <RPN score> <description>
  - <RPN score> <description>
EDGE_CASES:
  - <null/empty/boundary/etc>
  - <null/empty/boundary/etc>
MITIGATIONS:
  - <Preventative/Detective/Corrective/Tests>
  - <Preventative/Detective/Corrective/Tests>
```

## SYNPEC-IMPLEMENTATION (Stage 2 output)

```
SYNPEC-IMPLEMENTATION
TASK: <one-sentence>
CHANGED_FILES:
  - <file path>: <change summary>
  - <file path>: <change summary>
DEFENSIVE_GUARDS:
  - <guard description>
  - <guard description>
EDGES_COVERED:
  - <edge case addressed>
  - <edge case addressed>
PENDING_EDGES:
  - <edge case not addressed, reason>
```

## SYNPEC-AUDIT (Stage 3 output)

```
SYNPEC-AUDIT
CRITICAL: <count>
HIGH: <count>
MEDIUM: <count>
LOW: <count>
FINDINGS:
  - <severity> | <CWE/CVE> | <short description> | <exploit assessment>
  - <severity> | <CWE/CVE> | <short description> | <exploit assessment>
REMEDIATED:
  - <applied fix>
  - <applied fix>
UNREMEDIATED:
  - <remaining risk>
  - <remaining risk>
```

## SYNPEC-VERIFICATION (Stage 4 output)

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
  - <test name> <status>
```

## Chain Traceability

Every SYNPEC record should contain a reference to the previous stage's output hash or summary, ensuring that context is never lost:
- ANALYSIS references task
- IMPLEMENTATION references ANALYSIS
- AUDIT references ANALYSIS + IMPLEMENTATION
- VERIFICATION references ANALYSIS + IMPLEMENTATION + AUDIT

This ensures that any later stage can always trace back to a specific earlier finding.
