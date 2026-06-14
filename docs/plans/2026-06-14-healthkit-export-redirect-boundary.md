---
title: HealthKit Export Redirect Boundary
type: privacy
status: completed
date: 2026-06-14
---

# HealthKit Export Redirect Boundary

## Summary

Prevent validated HealthKit export requests from following HTTP redirects to a
different destination after endpoint validation. Build exports through a
dedicated ephemeral Alamofire 1.2.2 manager whose redirect delegate rejects
every redirect before any request is created.

## Priority

1. Keep sensitive HealthKit JSON on the explicitly configured HTTPS endpoint.
2. Install redirect denial before request dispatch, without shared-manager
   mutation or request-start races.
3. Preserve existing endpoint validation, payload limits, timeout, cookie
   isolation, cache controls, and user-confirmed export behavior.

## Requirements

- R1. HealthKit exports must use a dedicated `Alamofire.Manager` rather than
  `Manager.sharedInstance` or the top-level request helper.
- R2. The manager must use an ephemeral session configuration and return `nil`
  from `taskWillPerformHTTPRedirection` before requests are created.
- R3. The configured endpoint, JSON serialization, 64 KiB body limit,
  30-second timeout, cookie isolation, and `Cache-Control: no-store` behavior
  must remain unchanged.
- R4. Static source-order contracts must prove redirect denial precedes manager
  request dispatch and that the top-level `Alamofire.request(request)` call is
  absent from the export path.
- R5. Repository privacy guidance must document that redirected exports fail
  closed.

## Non-Goals

- Replacing or upgrading Alamofire, CocoaPods, Swift, or the Xcode project.
- Following same-host redirects or introducing an endpoint allowlist.
- Changing payload contents, HealthKit query scope, UI flow, or callback order.
- Claiming live device behavior without hosted Xcode validation and a
  controlled redirecting endpoint.

## Verification

- The focused redirect source-order contract and shell syntax check passed.
- A completed-plan baseline preflight passed.
- Six isolated hostile mutations were rejected for shared-manager dispatch,
  missing redirect denial, redirect acceptance, manager ordering,
  documentation, and completed plan evidence.
- `make check` passed from the repository and from `/tmp` through the absolute
  Makefile path. Both runs truthfully skipped `xcodebuild` because it is not
  installed on the Linux host.
- Shell syntax, both plist parses, exact intended-path review, unchanged
  project/dependency/workflow inspection, generated-artifact, untracked-file,
  conflict-marker, whitespace, and changed-line credential-pattern audits
  passed.
- Sequential security, correctness, maintainability, and test review found no
  actionable issue; Alamofire 1.2.2's source and README confirm the dedicated
  manager and redirect delegate APIs used by the implementation.
- One bounded exact-head hosted PR/check and code-scanning snapshot is required
  after push; pending jobs will not be polled or awaited.
