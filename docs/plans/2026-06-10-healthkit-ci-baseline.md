# HealthKit CI Baseline

Status: Completed

## Context

The repository had a privacy-focused `make check` gate and optional Xcode
project parsing, but no hosted workflow exercised the Apple toolchain path.

## Changes

- Added a GitHub Actions workflow on the supported `macos-15` runner so the
  privacy baseline and `xcodebuild -list` project parse run together.
- Pinned checkout by commit, granted read-only repository access, enabled
  stale-run cancellation, and limited the job to ten minutes.
- Kept the hosted job offline and free of HealthKit records, endpoint values,
  credentials, signing material, simulators, and devices.
- Extended the checker and project docs so hosted Xcode parsing remains part of
  the maintenance contract.

## Verification

- `make check`
- Workflow YAML parsing
- `git diff --check`
- Hosted macOS `xcodebuild -list` through `make check`
