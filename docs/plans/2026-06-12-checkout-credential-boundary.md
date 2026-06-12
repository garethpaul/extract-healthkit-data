# Checkout Credential Boundary

## Status: Completed

## Context

The hosted macOS privacy job only needs repository contents. Its checkout
credential should not remain in Git configuration while offline HealthKit and
Xcode project checks run.

## Objectives

- Disable checkout credential persistence without changing privacy coverage.
- Preserve the pinned action, read-only permissions, macOS runner, and Xcode
  project parse.
- Reject duplicate workflows, checkout steps, or boundary declarations.

## Work Completed

- Added `persist-credentials: false` to the pinned checkout step.
- Added exact static contracts for the sole workflow and checkout boundary.
- Updated the hosted privacy and security documentation.

## Verification

- `make lint`
- `make test`
- `make build`
- `make check`
- `sh -n scripts/check-baseline.sh`
- `git diff --check`
- Hostile workflow and plan mutations were rejected.

## Remaining Risk

Local Xcode, signing, HealthKit authorization, device execution, and live export
remain intentionally untested by this workflow-only change.
