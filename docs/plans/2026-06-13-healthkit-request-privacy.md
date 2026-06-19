---
title: HealthKit Export Request Privacy
type: privacy
status: completed
date: 2026-06-13
---

# HealthKit Export Request Privacy

## Summary

Isolate HealthKit export requests from shared HTTP cookie state and explicitly
mark their sensitive JSON bodies as non-cacheable before Alamofire queues them.

## Priority

1. Prevent ambient endpoint cookies from accompanying exported HealthKit data.
2. Tell clients and intermediaries not to store export request content.
3. Preserve the validated HTTPS endpoint, exact 30-day scope, payload bounds,
   and user-confirmed export flow.

## Requirements

- R1. Export requests must disable automatic HTTP cookie handling before send.
- R2. Export requests must set `Cache-Control: no-store` before send.
- R3. The existing JSON content type, 30-second timeout, 64 KiB encoded-body
  limit, and HTTPS endpoint validation must remain unchanged.
- R4. Static ordering contracts must prove cookie and cache protections are set
  before `Alamofire.request` queues the request.
- R5. Project privacy guidance must document the request-isolation boundary.
- R6. The green checkout credential boundary from PR #3 must be integrated by
  replaying its exact source patch without closing or modifying that PR.

## Non-Goals

- Replacing the vendored Alamofire version or changing transport libraries.
- Adding endpoint credentials, cookies, OAuth, or account configuration.
- Changing the export endpoint, payload schema, row filtering, or consent text.
- Claiming live device export behavior without Xcode, signing, HealthKit data,
  and a controlled endpoint.

## Implementation Units

### 1. Request Isolation

Files: `ExtractHealthKit/API.swift`

- Disable automatic cookie handling on the mutable request.
- Add an exact `Cache-Control: no-store` request header.
- Keep both protections ahead of serialization and request dispatch.

### 2. Static Privacy Contract

Files: `scripts/check-baseline.sh`

- Require both request protections exactly once.
- Prove they occur before `Alamofire.request`.
- Require completed verification evidence and updated privacy guidance.

### 3. Project Guidance

Files: `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`

- Document cookie isolation, non-storage intent, and platform validation limits.

## Verification Plan

- Run `make check`, `make lint`, `make test`, and `make build`.
- Remove cookie isolation and replace `no-store`; the privacy gate must reject
  both mutations.
- Move either protection after request dispatch; the ordering gate must reject
  the mutation.
- Run shell syntax, plist parsing, `git diff --check`, and intended-file secret
  scans.
- Take one bounded exact-head hosted check snapshot after push; do not poll.

## Verification

- A copied Linux privacy gate passed before hostile mutation testing; local
  `xcodebuild` remained unavailable.
- Removing `HTTPShouldHandleCookies = false` produced the expected `cookie isolation mutation failed` result.
- Replacing `Cache-Control: no-store` produced the expected `no-store mutation failed` result.
- Moving both protections after `Alamofire.request` produced the expected `ordering mutation failed` result.
- The rooted full gate, shell syntax, plist parsing, diff check, and intended-file
  secret scan passed.
- The exact pushed head still requires the bounded hosted macOS check because
  Swift compilation and device export cannot run on this Linux host.

## Work Completed

- Disabled automatic HTTP cookie handling on each HealthKit export request.
- Added an exact `Cache-Control: no-store` request header before serialization.
- Added exact-count and pre-dispatch ordering contracts to the privacy baseline.
- Updated project privacy, security, maintenance, and change guidance.
- Replayed the exact checkout credential boundary patch from source commit
  `81be4271080540403fd5f1f0dbfba3c4b2a9c9ea`; PR #3 remains open and unchanged.
