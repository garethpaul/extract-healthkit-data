---
title: Executable HealthKit Export Policy Tests
type: testing
date: 2026-06-16
status: completed
execution: code
---

# Executable HealthKit Export Policy Tests

## Status: Completed

## Summary

Execute the production export-row selection policy on maintained Swift hosts
without requiring the legacy UIKit and HealthKit application to build.

## Requirements

- Keep the exact 30-row newest-window and chronological output behavior in one
  production source file used by the app.
- Compile that source with a standalone harness using synthetic tuples only.
- Cover empty, short, exact-boundary, 31-row, trimming, invalid-field, and
  no-backfill behavior.
- Preserve compatibility with the legacy app source while allowing current
  `swiftc` to execute the isolated policy.
- Keep static privacy, Xcode project, and mutation-sensitive contracts intact.

## Work Completed

- Extracted the export-row policy into
  `ExtractHealthKit/HealthKitExportPolicy.swift` and added it to the app Sources
  phase.
- Kept `ViewController.swift` as the adapter from `Steps` models to JSON rows.
- Added a standalone Swift harness that runs against synthetic tuples and is
  invoked by `make check` whenever `swiftc` is available.
- Extended the static baseline to require the production delegation, executable
  cases, Xcode membership, and this completed evidence.

## Verification Completed

- The standalone harness executed the production policy for all documented
  synthetic cases.
- The maintained Make targets and external absolute-Makefile invocation passed.
- Hostile mutations to the policy limit, delegation, executable cases, project
  membership, and completion evidence were rejected.
- The harness does not prove HealthKit authorization, UIKit behavior, app
  signing, physical-device access, or live network export.
