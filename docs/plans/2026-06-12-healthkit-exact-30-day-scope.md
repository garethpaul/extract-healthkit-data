# HealthKit Exact 30-Day Scope

## Status: Completed

## Goal

Make the HealthKit query and export limits match the consent alert's explicit
promise that only step-count data from the last 30 days will be exported.

## Prioritized Engineering Work

1. **Use one exact 30-day boundary for collection and export (this change).**
   Replace the variable-length one-calendar-month query and 31-row export cap
   with a shared 30-day limit.
2. **Report actual network completion (follow-up).** Replace fire-and-forget
   export acceptance with bounded response handling that distinguishes server,
   transport, and serialization failures without logging health data.
3. **Publish query results to the UI once (follow-up).** Build the results array
   off the main thread and assign/reload it once on the main queue instead of
   dispatching a table reload for every daily statistic.
4. **Modernize the legacy Swift project (follow-up).** Migrate in a dedicated
   pass with a real compile/test gate rather than mixing syntax churn into this
   privacy-boundary correction.

## Requirements

- R1. A named constant must define the 30-day HealthKit export scope.
- R2. The HealthKit query start date must subtract that exact number of calendar
  days, not one calendar month.
- R3. Export payload construction must inspect no more than the same number of
  daily rows.
- R4. The alert must continue to disclose the last-30-days scope before the
  user confirms export.
- R5. Existing endpoint validation, row filtering, JSON byte limits, timeout,
  read-only authorization, and no-payload logging safeguards must remain.
- R6. The static baseline and project documentation must reject a return to a
  month-based query or a 31-row export cap.

## Verification

- `make check`.
- Hosted macOS project parsing through GitHub Actions.
- `git diff --check`.
- Mutation check: restoring `.CalendarUnitMonth, value: -1` must fail the
  static privacy baseline.
- Mutation check: raising the export limit to 31 must fail the static privacy
  baseline.

## Compatibility Boundary

This remains a legacy Swift sample that current Xcode can parse but not compile
without a separate language and dependency migration. This change therefore
uses the existing Swift-era APIs and relies on source-order/privacy contracts
plus hosted project parsing.

## Work Completed

- Added `HealthKitExportLookbackDays = 30` as the shared collection and export
  privacy boundary.
- Replaced the variable one-calendar-month query with subtraction of exactly 30
  calendar days.
- Tightened export payload construction from 31 inspected rows to the same
  30-day limit.
- Updated current privacy documentation and marked the earlier 31-row defensive
  boundary as superseded without rewriting its historical record.
- Extended the static baseline to reject month-based queries, 31-day constants,
  or drift between query and export limits.

## Verification Completed

- `make check` passes locally; Xcode parsing is skipped because this Linux host
  does not provide `xcodebuild`.
- `git diff --check` passes.
- Restoring `.CalendarUnitMonth, value: -1` makes `make check` fail.
- Raising `HealthKitExportLookbackDays` to 31 makes `make check` fail.
- GitHub Actions push run `27391707339` passed on `macos-15`.
- GitHub Actions pull-request run `27391708457` passed on `macos-15`; both
  hosted runs completed the Xcode project parse.
