---
title: Location-Independent HealthKit Verification
type: reliability
date: 2026-06-13
status: in progress
execution: code
---

# Location-Independent HealthKit Verification

## Summary

Resolve verification and Xcode project paths from the loaded Makefile so both
maintained gates work outside the repository directory.

## Requirements

- R1. Derive the repository root from `MAKEFILE_LIST`.
- R2. Root the privacy checker and `xcode-list` project path.
- R3. Preserve the caller-selected `XCODEBUILD` command.
- R4. Add mutation-sensitive contracts and actual `/tmp` verification.
- R5. Do not alter HealthKit, export, project, workflow, dependency, plist, or
  entitlement behavior.

## Verification Plan

- Run the complete privacy baseline at repository root and from `/tmp`.
- Dry-run `xcode-list` from `/tmp` with a harmless command substitute on Linux.
- Reject hostile Makefile, documentation, and completed-plan mutations.
- Run shell syntax, plist, diff, exact-path, secret, and artifact checks.

## Non-Goals

- Claiming an Xcode build, signing, HealthKit authorization, or live export.
