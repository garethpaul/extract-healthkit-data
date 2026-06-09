---
title: HealthKit Empty Export Guard
date: 2026-06-09
status: completed
execution: code
---

## Context

The export confirmation action constructed a payload inline and attempted the
network request even when the HealthKit query had not produced any step rows.
For a privacy-sensitive sample, the export action should be explicit about both
the payload shape and the fact that no network request is made when there is no
step data to export.

## Goals

- Keep the exported payload shape isolated and easy to review.
- Avoid posting empty HealthKit export payloads.
- Preserve the explicit HTTPS endpoint failure message.
- Keep the static privacy baseline useful without Xcode installed.

## Implementation

- Added `exportPayload(steps:)` to construct the `date`/`value` payload.
- Added an `outData.isEmpty` guard before `postRequest`.
- Extended `scripts/check-baseline.sh` to preserve the empty-export guard and
  extracted payload builder.
- Updated README, VISION, and CHANGES with the export behavior.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

Full Xcode project parsing is still skipped locally because `xcodebuild` is
not installed in this environment.
