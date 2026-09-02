# Pipeline Chain Templates

Concrete examples of multi-skill pipeline execution. Each template shows the full SYN-SPEC chain that flows between stages.

---

## Template 1: Feature Implementation (Full Pipeline)

```
User: "Implement a payment gateway with Stripe integration"
```

### Stage 1 → synapse-foresight

```
SYNPEC-ANALYSIS
TASK: Implement Stripe payment gateway integration
CWD: /project
FILES: [none yet — greenfield]
RISKS:
  - 800 Concurrency: double-charge on race condition during payment capture
  - 750 State: partial payment states (authorized but not captured) not handled
  - 600 Security: webhook signature verification missing → spoofed confirmations
  - 500 Scale: idempotency keys not implemented → duplicate charges on retry
  - 400 Boundary: currency precision errors (float vs decimal)
EDGE_CASES:
  - Null/empty: missing amount, null currency, empty card token
  - Boundary: zero amount, negative amount, max integer amount
  - Concurrent: simultaneous payment attempts for same order
  - State: payment authorized but customer cancels before capture
  - Timing: webhook arrives before API response returns
MITIGATIONS:
  - Preventative: Use decimal arithmetic, idempotency keys, webhook signature check
  - Detective: Reconciliation job comparing API charges vs webhook events
  - Corrective: Dead letter queue for failed webhook processing
  - Tests: Property test for decimal arithmetic, fuzz test for webhook payload
```

### Stage 2 → synapse-coder

```
SYNPEC-IMPLEMENTATION
TASK: Implement Stripe payment gateway integration
CHANGED_FILES:
  - src/payments/stripe.ts: Stripe client initialization, charge, capture, refund
  - src/payments/types.ts: PaymentIntent, PaymentStatus types
  - src/payments/webhooks.ts: Webhook handler with signature verification
  - src/payments/idempotency.ts: Idempotency key generation and storage
  - src/payments/errors.ts: Payment-specific error types
  - tests/payments/stripe.test.ts: Unit tests for charge, capture, refund
  - tests/payments/webhooks.test.ts: Webhook handler tests
DEFENSIVE_GUARDS:
  - All monetary amounts use Decimal type, never float
  - Idempotency key required on every charge request
  - Webhook signature verified before processing
  - Payment state machine enforced (pending → authorized → captured → settled)
  - Timeout on all Stripe API calls (5s default)
EDGES_COVERED:
  - Null/empty: validated at API boundary, returns 400
  - Boundary: amount bounds checked (0.50 min, 999999.99 max)
  - Idempotency: duplicate requests return cached response
  - State machine: illegal state transitions rejected with clear error
PENDING_EDGES:
  - Webhook-before-API race: handled with 500ms polling fallback
  - Stripe outage: no circuit breaker yet — recommended for M2
```

### Stage 3 → synapse-sentinel

```
SYNPEC-AUDIT
CRITICAL: 1
HIGH: 2
MEDIUM: 3
LOW: 1
FINDINGS:
  - Critical | CWE-327 | Webhook secret stored in env var, not encrypted at rest | Exploitable
  - High | CWE-89 | Refund query parameter not sanitized (SQL injection vector) | Conditional
  - High | CWE-347 | Idempotency key predictable (sequential counter) | Conditional
  - Medium | CWE-200 | Error messages expose Stripe charge IDs to client | Theoretical
  - Medium | CWE-400 | No rate limiting on webhook endpoint | Theoretical
  - Medium | CWE-770 | No request size limit on webhook body | Theoretical
  - Low | CWE-532 | Payment amounts logged at INFO level | Theoretical
REMEDIATED:
  - Sanitized refund query parameter with parameterized query
  - Idempotency key changed to UUID v4
  - Error responses stripped of internal IDs
  - Webhook endpoint rate-limited to 100 req/min
  - Request body size limited to 64KB
UNREMEDIATED:
  - Webhook secret encryption at rest requires vault integration (M2)
  - Payment amount logging needs log-level policy review (M2)
```

### Stage 4 → synapse-tester

```
SYNPEC-VERIFICATION
PASS: 47
FAIL: 0
COVERAGE_LINE: 94%
COVERAGE_BRANCH: 88%
FUZZ_PASS: 1200
FUZZ_REG: 0
CI_GATE_STATUS: PASS
REGRESSION_TESTS:
  - test_charge_with_valid_card PASS
  - test_charge_rejects_null_amount PASS
  - test_idempotency_returns_cached PASS
  - test_webhook_rejects_invalid_signature PASS
  - test_state_machine_rejects_invalid_transition PASS
  - test_decimal_arithmetic_no_precision_loss PASS
  - test_concurrent_charges_do_not_double_charge PASS
  - test_refund_sanitization_prevents_injection PASS
  - fuzz_webhook_payload_1200_cases PASS
  - property_decimal_roundtrip PASS
  - property_idempotency_key_uniqueness PASS
```

---

## Template 2: Security Fix Pipeline

```
User: "Fix this SQL injection vulnerability in the search endpoint"
```

### Stage 1 → synapse-sentinel (skip foresight — targeted fix)

```
SYNPEC-AUDIT
CRITICAL: 1
HIGH: 0
MEDIUM: 0
LOW: 0
FINDINGS:
  - Critical | CWE-89 | SQL injection in search endpoint query parameter | Exploitable
    - Location: src/api/search.ts:47
    - Payload: `'; DROP TABLE users; --`
    - Impact: Full database compromise
    - Root cause: String interpolation in SQL query
REMEDIATED:
  - [pending — hand to synapse-coder]
UNREMEDIATED:
  - [all — awaiting fix]
```

### Stage 2 → synapse-coder

```
SYNPEC-IMPLEMENTATION
TASK: Fix SQL injection in search endpoint
CHANGED_FILES:
  - src/api/search.ts: Replaced string interpolation with parameterized query
  - tests/api/search.test.ts: Added injection payload test cases
DEFENSIVE_GUARDS:
  - All queries use parameterized statements
  - Input validation added for search term (max 500 chars, no special SQL chars)
  - Added WAF-style pattern detection for common injection payloads
EDGES_COVERED:
  - Classic injection: `' OR 1=1 --`
  - Union injection: `' UNION SELECT * FROM users --`
  - Time-based: `'; WAITFOR DELAY '0:0:5' --`
  - Second-order: injection stored in DB and retrieved later
PENDING_EDGES:
  - None
```

### Stage 3 → synapse-tester

```
SYNPEC-VERIFICATION
PASS: 12
FAIL: 0
COVERAGE_LINE: 100%
COVERAGE_BRANCH: 100%
FUZZ_PASS: 5000
FUZZ_REG: 0
CI_GATE_STATUS: PASS
REGRESSION_TESTS:
  - test_search_returns_results PASS
  - test_injection_classicPayload BLOCKED PASS
  - test_injection_unionPayload BLOCKED PASS
  - test_injection_timeBased BLOCKED PASS
  - test_injection_secondOrder BLOCKED PASS
  - test_input maxLength_enforced PASS
  - fuzz_search_endpoint_5000_cases PASS
```

---

## Template 3: Research → Plan → Implement

```
User: "Research the best rate limiting approach, plan the implementation, then build it"
```

### Chain: synapse-scholar → synapse-planner → synapse-coder → synapse-tester

```
Stage 1: synapse-scholar produces research report on rate limiting strategies
  → Output: comparison of token bucket, sliding window, fixed window
  → Recommendation: token bucket for API, sliding window for auth endpoints

Stage 2: synapse-planner decomposes into implementation tasks
  → Output: 3 epics, 8 tasks, critical path identified
  → Milestone 1: Core rate limiter (2 days)
  → Milestone 2: Redis-backed distributed limiter (3 days)
  → Milestone 3: Dashboard + alerting (1 day)

Stage 3: synapse-coder implements with foresight from research
  → Output: rate limiter middleware, Redis adapter, test suite

Stage 4: synapse-tester verifies with load testing
  → Output: rate limit accuracy confirmed, no false positives
```

---

## Template 4: Documentation Pipeline

```
User: "Write comprehensive API docs for the auth module"
```

### Chain: synapse-coder → synapse-writer

```
Stage 1: synapse-coder analyzes the auth module
  → Output: inventory of all public functions, types, and endpoints
  → identifies undocumented parameters, missing return types

Stage 2: synapse-writer produces documentation
  → Output: API reference with examples, usage guide, migration notes
  → includes code samples for every public function
  → cross-references existing docs
```

---

## Template 5: Quick Fix (Minimal Pipeline)

```
User: "Fix this bug" (simple, isolated)
```

### Chain: synapse-coder (quick mode)

```
Stage 1: synapse-coder in quick mode
  → Phase 2: Plan (skip reconnaissance)
  → Phase 3: Implement
  → Phase 4: Verify
  → Done — no pipeline overhead for trivial changes
```

---

## Template 6: Audit & Harden

```
User: "Audit this project for security issues and fix what you find"
```

### Chain: synapse-sentinel → synapse-coder → synapse-tester → synapse-sentinel (verify)

```
Stage 1: synapse-sentinel full security audit
  → Output: finding inventory with severities

Stage 2: synapse-coder fixes all HIGH and CRITICAL findings
  → Output: code changes with defensive guards

Stage 3: synapse-tester verifies fixes
  → Output: regression tests, fuzz tests pass

Stage 4: synapse-sentinel re-audits fixed code
  → Output: verification that findings are resolved
```

---

## Handoff Protocol

When chaining skills, always pass:

1. **Previous stage SYN-SPEC output** — the full document
2. **Working directory** — so the next stage can locate files
3. **File list** — all files touched or referenced
4. **Constraints** — any limitations or requirements from earlier stages
5. **Decision history** — why earlier choices were made

Never pass:
- Assumptions without evidence
- Vague descriptions ("fix the thing")
- Implementation details the next skill should determine
