---
title: HealthKit Export Harness Signal Cleanup
type: reliability
date: 2026-06-18
status: planned
execution: code
---

# HealthKit Export Harness Signal Cleanup

## Status: Planned

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
