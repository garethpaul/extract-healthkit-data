---
title: HealthKit Endpoint Query Fragment Guard
date: 2026-06-09
status: completed
execution: code
---

## Context

The export endpoint guard required HTTPS, a non-empty host, and no embedded
username/password userinfo. It still accepted query strings and fragments in the
configured URL, which can hide token-like values or routing state in local app
metadata.

## Goals

- Reject configured export endpoints that include query strings or fragments.
- Preserve the existing HTTPS, host, and userinfo validation.
- Keep the committed endpoint value empty.
- Extend the static baseline and documentation for the endpoint contract.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

Full Xcode project parsing is still skipped locally because `xcodebuild` is not
installed in this environment.
