# Changes

## 2026-06-26

- **2026-06-26 10:41 PDT — Priority: privacy/correctness.** Added controller
  ownership for one in-flight HealthKit export so repeated confirmations cannot
  queue duplicate sensitive payloads before the first request completes.
  Updated `ViewController.swift`, the static baseline, maintainer guidance,
  manual device checklist, and completed plan. Five hostile mutations, all four
  local aliases, and the external absolute-Makefile gate passed; the Linux host
  lacks `swiftc` and Xcode, so executable policy and platform behavior remain
  hosted macOS boundaries. Finding: transport cancellation was not the issue;
  duplicate queue admission had no ownership state. Blockers: none. Next
  action: publish the PR, verify hosted gates, and merge only the green SHA.

## 2026-06-18

- Bounded the HealthKit statistics query itself to the exact 30-day sample
  window instead of calculating over every stored step-count sample.
- Built query results in a callback-local snapshot and published both export
  and table state together on the main queue.

## 2026-06-16

- Extracted the production HealthKit export-row policy into a Foundation-only
  source file shared by the legacy app and a standalone Swift harness.
- Added executable synthetic coverage for the 30-row window, chronological
  order, field trimming, invalid rows, and no-backfill behavior.

## 2026-06-14

- Added a dedicated ephemeral HealthKit export manager that rejects HTTP redirects.
- Required a transport-error-free HTTP 2xx response before reporting a queued
  HealthKit export as completed.

## 2026-06-13

- Made Make verification independent of the caller's working directory.
- Selected the newest 30 collected HealthKit daily buckets for export while
  preserving chronological payload order when the query yields 31 boundaries.
- Published each completed HealthKit statistics result to the table once on the
  main queue instead of reloading for every enumerated day.
- Disabled cookie handling and added Cache-Control: no-store before HealthKit
  export serialization and request dispatch.
- Added a truthful physical-device checklist for read-only authorization,
  exact 30-day consent, controlled export inspection, failures, and redacted
  evidence; the checklist remains unexecuted in the Linux maintenance session.

## 2026-06-12

- Stopped the hosted macOS checkout from persisting its credential and added an
  exact contract for the sole workflow and checkout step.
- Replaced the variable-length one-calendar-month HealthKit query with an exact
  30-day lookback matching the export confirmation alert.
- Reused the same 30-day constant as the maximum inspected export rows so data
  collection and egress cannot drift to a 31-day scope.

## 2026-06-10

- Bounded HealthKit export construction to 31 inspected daily rows and rejected
  encoded JSON payloads over 64 KiB before network handling.
- Added ordering guards and documentation for both privacy-oriented egress
  limits.
- Added a pinned, read-only `macos-15` GitHub Actions workflow that runs the
  privacy baseline and hosted Xcode project parse.
- Kept hosted checks offline and free of HealthKit records, endpoint values,
  credentials, signing material, simulators, and devices.

## 2026-06-09

- Added a bounded timeout to HealthKit export requests before network handling.
- Filtered HealthKit export rows to valid date/value fields before POST.
- Replaced raw HealthKit authorization/query error logging with generic failure
  messages.
- Rejected non-JSON-serializable HealthKit export payloads before building the
  POST body.
- Rejected HealthKit export endpoints with query strings or fragments.
- Rejected HealthKit export endpoints with embedded username/password userinfo.
- Extracted HealthKit export payload construction into a dedicated helper.
- Skipped export network requests when no step rows are available.
- Added a static baseline guard and plan for the empty-export behavior.
- Added source-control guardrails for local signing and archive artifacts.

## 2026-06-08

- Moved the HealthKit export endpoint to the `HealthKitExportEndpoint` app
  metadata key and require HTTPS before sending.
- Require configured export endpoints to include a non-empty host before
  sending HealthKit payloads.
- Removed export payload logging and query-error `abort()` behavior.
- Requested read-only HealthKit step-count authorization.
- Added static privacy, entitlement, Podfile, plist, and source verification via
  `make check`.
