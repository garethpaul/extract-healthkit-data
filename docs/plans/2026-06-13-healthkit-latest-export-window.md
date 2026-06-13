---
title: HealthKit Latest Export Window
type: privacy
date: 2026-06-13
status: planned
execution: code
---

# HealthKit Latest Export Window

## Summary

Select the newest 30 collected daily HealthKit buckets for export while keeping
the request payload in chronological order.

## Problem

HealthKit statistics are collected oldest-to-newest from a start boundary 30
calendar days before the current time. That interval can contain 31 partial or
complete daily buckets. The current payload builder inspects the first 30 rows,
so it can omit the newest day even though the confirmation alert promises the
last 30 days.

## Requirements

- R1. Inspect no more than `HealthKitExportLookbackDays` daily buckets.
- R2. When more buckets are present, select the newest bounded window.
- R3. Preserve chronological ordering in the emitted JSON payload.
- R4. Preserve invalid-field filtering, the exact shared 30-day constant,
  endpoint validation, request privacy isolation, and the 64 KiB body limit.
- R5. Add static contracts and mutation-sensitive fixture coverage for a
  31-bucket input where the oldest bucket is excluded and the newest remains.
- R6. Do not claim Swift compilation, HealthKit authorization, signed-device
  execution, or live export from the Linux maintenance environment.

## Verification Plan

- Run the focused latest-window fixture contract.
- Run `make check`, `make lint`, `make test`, and `make build`.
- Reject mutations that restore oldest-first truncation, omit chronological
  restoration, weaken the 31-bucket fixture, or falsify completion evidence.
- Run shell syntax, plist parsing, `git diff --check`, exact-path review,
  generated-artifact inspection, and credential/signing scans.
- Take one bounded exact-head hosted snapshot after push; do not poll.

## Non-Goals

- Changing HealthKit authorization, query dates, endpoint configuration,
  payload fields, UI publication, or network response handling.
- Modernizing the legacy Swift project or vendored networking code.
