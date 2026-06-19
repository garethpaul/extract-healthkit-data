---
title: HealthKit Single Main-Queue UI Publication
type: reliability
date: 2026-06-13
status: completed
execution: code
---

# HealthKit Single Main-Queue UI Publication

## Summary

Collect the complete HealthKit statistics result before publishing table data,
then update both the table backing array and visible table exactly once on the
main queue.

## Requirements

- R1. Do not call `sortArray()` from inside the per-statistic enumeration body.
- R2. Call `sortArray()` exactly once after enumeration completes successfully.
- R3. Assign the reversed `outData` snapshot to `tableData` inside the same
  main-queue block that calls `reloadData()`.
- R4. Preserve the exact 30-day query, row filtering, generic error logging,
  read-only authorization, export payload, and public controller API.
- R5. Add section-scoped static contracts and mutation evidence.

## Verification Plan

- Run the focused source-order contract for enumeration, publication, main
  queue assignment, and reload ordering.
- Run `make check`, `make lint`, `make test`, and `make build` on Linux.
- Reject hostile mutations that restore per-row publication, move data-source
  mutation off the main queue, duplicate publication, or weaken plan/docs.
- Require the stacked pull request's hosted macOS project-parse check.

## Non-Goals

- Changing HealthKit authorization, query dates, values, or export behavior.
- Claiming a signed build, device query, UI interaction, or runtime thread trace.
- Modernizing legacy Swift, Xcode, or CocoaPods dependencies.

## Verification

- The focused Python 3.12.8 source-order contract passed: `sortArray()` contains
  one main-queue dispatch, one backing-array assignment, and one reload in that
  order, while the query handler publishes once after enumeration.
- `make check`, `make lint`, `make test`, and `make build` passed the maintained
  privacy baseline; Xcode project parsing was explicitly skipped because
  `xcodebuild` is unavailable on Linux.
- Eight isolated hostile mutations were rejected across per-row publication,
  off-main data mutation, duplicate/missing publication, docs, and plan status.
- Shell syntax, git diff, exact-path, unchanged project/dependency/workflow,
  signing/credential-like addition, and generated-artifact inspections passed.
- Xcode, a signed HealthKit-capable device query, UI interaction, and runtime
  thread tracing were not performed locally. The hosted macOS project parse
  remains required.
