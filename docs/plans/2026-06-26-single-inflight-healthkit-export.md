---
title: Single In-Flight HealthKit Export
type: privacy
date: 2026-06-26
status: completed
execution: code
---

# Single In-Flight HealthKit Export

## Problem

After a user confirmed an export, the controller did not retain queue ownership.
The export button could therefore present another confirmation and queue the
same sensitive HealthKit payload again while the first request was unresolved.

## Decision

- Keep one controller-owned `exportInFlight` flag.
- Reject another export action before presenting its confirmation while that
  flag is set.
- Claim ownership immediately before calling `postRequest`.
- Release ownership in the asynchronous completion and the synchronous
  not-queued path.
- Preserve the endpoint, payload, redirect, timeout, cookie, cache, response,
  and generic-diagnostic boundaries.

## Verification Completed

- The new ownership assertion failed before the Swift implementation changed.
- The focused privacy baseline passed after the controller guard was added.
- Five isolated hostile mutations were rejected for removing the flag,
  weakening the entry guard, removing the pre-queue claim, omitting completion
  release, and omitting queue-rejection release.
- Full local Make aliases and the external absolute-Makefile gate passed where
  tools were available.
- The Linux host lacked `swiftc` and Xcode; executable policy testing and Xcode
  project parsing remain a hosted macOS validation boundary.

## Scope Boundaries

This change does not retry, cancel, or deduplicate server-side requests, alter
the HealthKit query or payload, disable UI controls, or modernize networking.
It only prevents a controller from admitting a second export until ownership
of the first request is released.
