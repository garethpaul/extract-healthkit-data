---
title: Extract HealthKit privacy baseline
date: 2026-06-08
status: completed
execution: code
---

## Context

This repository is a legacy Swift / iOS 8 HealthKit sample that reads step
counts, displays recent daily values, and can export those values through an
Alamofire request. The current environment does not include Xcode, so full app
builds and HealthKit device verification must happen on a macOS/Xcode machine.

The existing source hardcodes a remote export endpoint, logs the export payload,
requests write access for step count even though it only reads data, and aborts
the app on a HealthKit query error.

## Goals

- Keep the HealthKit read and table-view flow intact.
- Move export endpoint configuration into app metadata instead of source code.
- Avoid logging step payload data.
- Request read-only HealthKit access for step count.
- Handle HealthKit query errors without aborting the app.
- Add static checks for privacy, entitlement, project, and dependency
  guardrails.

## Scope Boundaries

- Do not migrate the project to a modern Swift or HealthKit API in this pass.
- Do not add background export, analytics, or new network behavior.
- Do not change the exported payload shape beyond endpoint configuration.
- Do not add real HealthKit data fixtures.

## Implementation Units

### U1: Health-data export boundary

Files: `ExtractHealthKit/API.swift`, `ExtractHealthKit/Info.plist`,
`ExtractHealthKit/ViewController.swift`

Approach: Read `HealthKitExportEndpoint` from `Info.plist`, require HTTPS before
sending, return a success flag from `postRequest`, and remove payload logging.

Verification: Static baseline checks reject the previous hardcoded endpoint and
payload logging.

### U2: HealthKit permission and error posture

Files: `ExtractHealthKit/ViewController.swift`, `ExtractHealthKit/Info.plist`

Approach: Request step-count read access only, keep HealthKit usage strings in
the app plist, and return from query errors instead of aborting.

Verification: Static baseline checks confirm read-only authorization, HealthKit
usage text, and no query-error `abort()`.

### U3: Maintenance guardrails

Files: `Makefile`, `scripts/check-baseline.sh`, `README.md`, `VISION.md`,
`CHANGES.md`

Approach: Add a repeatable Linux-friendly baseline for source, plist, Podfile,
entitlement, and project invariants. Run `xcodebuild -list` when available.

Verification: `scripts/check-baseline.sh`, `make check`, and `git diff --check`
pass locally; full Xcode build remains a macOS follow-up.
