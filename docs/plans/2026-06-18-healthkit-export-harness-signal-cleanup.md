---
title: HealthKit Export Harness Signal Cleanup
type: reliability
date: 2026-06-18
status: completed
execution: code
---

# HealthKit Export Harness Signal Cleanup

## Status: Completed

## Summary

Make the standalone HealthKit export policy runner remove its temporary build
directory when interrupted while `swiftc` is still running.

## Baseline

The runner removes its build directory after success and compiler failure, but
its exit-only signal traps leave `healthkit-export-policy-tests.*` behind after
`TERM` under the repository's POSIX `/bin/sh` execution path.

## Requirements

- Invoke cleanup directly from each signal handler before returning the
  conventional signal-derived status.
- Keep normal exit cleanup and existing compiler/test behavior unchanged.
- Add a mutation-sensitive static contract that rejects exit-only handlers.
- Verify success, compiler failure, and bounded termination with isolated fake
  compilers and temporary directories.

## Verification Plan

- Run `sh -n` on the runner and baseline gate.
- Run `make check` from the repository and an external directory.
- Exercise success, compiler-failure, and `TERM` cleanup paths with bounded
  fake compilers.
- Mutate the direct cleanup call and prove the baseline gate rejects it.
- Record the implementation commit and exact-head hosted results only after
  they exist.

## Verification Results

- `sh -n` passed for the export policy runner and baseline gate.
- Repository and external-directory `make check` passed with truthful local
  skips for unavailable `swiftc` and `xcodebuild`.
- Isolated fake-compiler probes covered success, compiler failure status 42,
  and bounded `TERM` cleanup; every temporary audit directory was empty after
  completion.
- Mutations removing direct signal cleanup or restoring the exit-only `TERM`
  binding were rejected by the maintained baseline contract.
- Diff, generated-artifact, and high-confidence secret audits passed.
- Implementation commit `c36ca4164205f183424c1a5e3f67f09d7a72c347`
  passed exact-head push run `27746646358` and pull-request run `27746648370`
  on macOS.
