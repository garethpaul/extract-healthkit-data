---
title: HealthKit Export Response Validation
type: reliability
date: 2026-06-14
status: in-progress
execution: code
---

# HealthKit Export Response Validation

## Summary

Distinguish a queued HealthKit export from a completed export. Observe the
transport result and require an HTTP 2xx response before reporting generic
success, without logging response bodies, endpoint details, or raw errors.

## Prioritized Engineering Tasks

1. Add a completion result to the existing preflight-and-queue helper.
2. Treat transport errors, missing HTTP responses, and non-2xx status codes as
   export failures.
3. Keep preflight rejection synchronous and label it as a request that was not
   queued rather than assuming only endpoint configuration can fail.
4. Add source-order and documentation contracts for response validation and
   privacy-preserving diagnostics.

## Requirements

- R1. `postRequest` must continue returning `false` for preflight rejection.
- R2. A queued request must invoke completion on the existing Alamofire main
  response queue.
- R3. Completion succeeds only when no transport error exists and the HTTP
  status is from 200 through 299.
- R4. User-visible diagnostics must not include HealthKit payloads, endpoint
  values, response bodies, or raw transport errors.
- R5. Existing endpoint, redirect, timeout, cookie, cache, payload-shape, and
  payload-size protections must remain unchanged.

## Non-Goals

- Retrying exports or changing timeout policy.
- Parsing response bodies or adding server-specific response schemas.
- Claiming device-runtime verification from the Linux maintenance host.

## Verification

- Pending implementation and bounded validation.
