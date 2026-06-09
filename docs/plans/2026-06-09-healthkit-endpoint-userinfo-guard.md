---
title: HealthKit Endpoint Userinfo Guard
date: 2026-06-09
status: completed
execution: code
---

## Context

The export endpoint guard required HTTPS and a non-empty host, but a configured
URL could still include embedded username/password userinfo such as
`https://user:pass@example.com/export`. HealthKit export endpoints should not
carry credentials in URLs.

## Goals

- Reject configured export endpoints with embedded URL userinfo.
- Preserve the existing HTTPS and host validation.
- Keep the committed endpoint value empty.
- Extend the static baseline and documentation for the endpoint contract.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

Full Xcode project parsing is still skipped locally because `xcodebuild` is not
installed in this environment.
