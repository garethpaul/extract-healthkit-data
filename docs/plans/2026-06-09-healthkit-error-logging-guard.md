# HealthKit Error Logging Guard

status: completed

## Context

The app already avoids logging export payloads, but HealthKit authorization and
statistics query failures still interpolated raw error descriptions into
`println` calls. Those descriptions are not needed for the sample flow and can
surface platform details in logs.

## Objectives

- Keep the existing HealthKit authorization and query control flow.
- Replace raw HealthKit error descriptions with generic failure messages.
- Extend the static baseline so raw HealthKit error descriptions are not
  reintroduced.
- Document the logging boundary for privacy-sensitive HealthKit code.

## Work Completed

- Replaced authorization failure logging with a generic message.
- Replaced statistics query failure logging with a generic message.
- Extended `scripts/check-baseline.sh` to reject `error.description` and
  `error.localizedDescription` in `ViewController.swift`.
- Documented the guard in README, SECURITY, VISION, and CHANGES.

## Verification

- `sh -n scripts/check-baseline.sh`
- `scripts/check-baseline.sh`
- `make check`
- `make lint`
- `make test`
- `make build`
- `git diff --check`
