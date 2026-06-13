---
title: HealthKit Manual Authorization And Export Verification
type: verification
status: planned
date: 2026-06-13
---

# HealthKit Manual Authorization And Export Verification

## Summary

Document a repeatable Apple-platform checklist for the privacy-sensitive
authorization, query, confirmation, and export flow without misrepresenting
static or hosted project checks as device runtime evidence.

## Priority

1. Make the required HealthKit-capable device evidence explicit.
2. Verify read-only authorization, exact 30-day presentation, confirmation,
   request privacy, and failure behavior with synthetic or tester-owned data.
3. Keep platform limitations and evidence recording truthful.

## Requirements

- R1. The checklist must require a compatible macOS/Xcode/CocoaPods toolchain,
  valid signing, and a HealthKit-capable physical device with tester-owned data.
- R2. The checklist must verify read-only step-count authorization and deny-path
  behavior without claiming access to other HealthKit data.
- R3. The checklist must verify populated and empty query results, the exact
  30-day confirmation text, cancellation, and explicit user confirmation.
- R4. Export verification must use a controlled HTTPS endpoint and inspect the
  POST method, JSON content type, no-store header, absent cookies, body bounds,
  and absence of credentials or unexpected health fields.
- R5. Failure checks must cover missing endpoint configuration, denied
  authorization, query failure, endpoint failure, and no raw health-data logs.
- R6. Evidence must record commit, Xcode/iOS/device versions, endpoint ownership,
  observed results, and screenshots/logs scrubbed of health data and secrets.
- R7. Static Linux checks and hosted Xcode project parsing must remain clearly
  labeled as non-runtime evidence.
- R8. The maintenance gate must enforce the checklist sections, core privacy
  assertions, completed verification evidence, and roadmap update.

## Non-Goals

- Claiming that this Linux implementation session performed the device run.
- Adding real HealthKit fixtures, endpoint values, credentials, or signing data.
- Modernizing Swift, dependencies, HealthKit APIs, or the Xcode project.
- Replacing the manual device flow with incomplete simulator or browser tests.

## Implementation Units

### 1. Manual Device Checklist

Files: `docs/manual-healthkit-verification.md`

- Define prerequisites, authorization/query, confirmation/export, privacy,
  failure, and evidence-recording steps.
- Require tester-owned synthetic or non-sensitive data and a controlled endpoint.

### 2. Maintenance Contract

Files: `scripts/check-baseline.sh`, this plan

- Require the checklist and its privacy-sensitive assertions.
- Reject weakened device, endpoint, consent, cookie, logging, and limitation
  language as isolated hostile mutations.

### 3. Project Guidance

Files: `README.md`, `AGENTS.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`

- Link the checklist, define what evidence is still outstanding, and move the
  documentation priority out of the roadmap without claiming execution.

## Verification Plan

- Run `make check`, `make lint`, `make test`, and `make build` on Linux, with the
  expected explicit `xcodebuild` skip.
- Apply isolated hostile mutations to the physical-device prerequisite,
  read-only authorization, exact 30-day confirmation, controlled HTTPS endpoint,
  cookie/no-store inspection, redacted evidence, platform limitation, roadmap,
  and plan status; require each mutation to fail.
- Run shell syntax, plist parsing, `git diff --check`, exact-path review, signing
  and credential-like addition inspection, and generated-artifact inspection.
- Take one bounded exact-head hosted check snapshot after push; do not poll.

## Risks

- Documentation cannot prove the runtime behavior was exercised.
- Legacy Swift and CocoaPods versions may prevent a modern Xcode/device run.
- Endpoint inspection can expose health data if the tester does not control and
  securely clean up the capture environment.
