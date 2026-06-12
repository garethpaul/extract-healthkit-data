# HealthKit Export Volume Bounds

## Status: Completed

## Goal

Keep sensitive HealthKit egress within the sample's stated 30-day scope and
prevent unexpectedly large JSON bodies from reaching network handling.

## Changes

- Stop export payload construction after inspecting 31 step rows, covering the
  maximum number of daily buckets in the displayed 30-day range.
- Retain existing date/value field filtering within that bounded input window.
- Reject serialized JSON bodies larger than 64 KiB before assigning the request
  body or invoking Alamofire.
- Add source-order guards proving row and byte limits execute before append and
  send side effects.
- Document the limits in the README, security policy, vision, and changelog.

## Verification

- `make check`
- `git diff --check`
- A mutation moving the byte check after `Alamofire.request` fails the ordering
  guard.
- A mutation moving the row check after payload append fails the ordering guard.

The project remains a legacy Swift sample; hosted macOS verification parses the
Xcode project but does not claim modern Swift compilation compatibility.

## Superseded Boundary

The original 31-row defensive cap was tightened on 2026-06-12 by
`2026-06-12-healthkit-exact-30-day-scope.md`. Current collection and export use
one exact 30-day constant so the implementation matches the consent alert.
