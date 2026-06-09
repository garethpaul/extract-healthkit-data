---
title: HealthKit Signing Artifact Guard
date: 2026-06-09
status: completed
execution: code
---

## Context

The app requires HealthKit entitlements and must be signed locally to run on a
device. That workflow can create provisioning profiles, signing certificates,
certificate requests, app archives, and archive intermediates near the project.
Those files can identify developer accounts or contain private signing
material, so they should stay out of source control.

## Goals

- Ignore local signing and archive artifacts created by Xcode or manual setup.
- Fail the static baseline if signing or archive artifacts become tracked.
- Document that HealthKit endpoint configuration and signing material are local
  only.
- Preserve the existing HealthKit endpoint and empty-export guards.

## Implementation

- Added ignore patterns for provisioning profiles, signing certificates,
  certificate requests, `.xcarchive` bundles, and archive intermediates.
- Extended `scripts/check-baseline.sh` to require those ignore patterns and
  reject tracked signing or archive artifacts.
- Updated README, VISION, SECURITY, and CHANGES with the source-control
  boundary.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

Full Xcode project parsing is still skipped locally because `xcodebuild` is not
installed in this environment.
