---
title: HealthKit Endpoint Host Validation
date: 2026-06-08
status: completed
execution: code
---

## Context

The export endpoint guard required the `https` scheme before sending HealthKit
step-count payloads, but it did not require a host. A malformed value could pass
the scheme check while still not being a usable remote endpoint.

## Goals

- Keep export endpoint configuration in app metadata.
- Require HTTPS and a non-empty host before sending.
- Preserve the existing `false` return path when the endpoint is invalid.
- Keep the static baseline useful without Xcode installed.

## Implementation

- Added host presence validation to `exportEndpointURL()`.
- Extended the baseline script to require the host guard.
- Updated README, VISION, and CHANGES to describe the endpoint contract.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

Full Xcode build verification is still unavailable locally because `xcodebuild`
is not installed.
