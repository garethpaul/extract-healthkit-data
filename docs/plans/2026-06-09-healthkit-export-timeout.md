# HealthKit Export Timeout

Status: Completed
Date: 2026-06-09

## Goal

Keep HealthKit export requests from relying on implicit network timeout behavior
when sending sensitive step-count payloads to the configured endpoint.

## Changes

- Added a named HealthKit export timeout constant.
- Applied the timeout to the export `NSMutableURLRequest` before Alamofire
  handles it.
- Extended the static baseline, README, security notes, changelog, and vision
  with the bounded export timeout contract.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
