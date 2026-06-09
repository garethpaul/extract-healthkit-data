# HealthKit Export Row Validation

status: completed

## Context

The export path already skipped network requests when there were no collected
step rows and validated the overall JSON payload shape before serialization.
The payload helper still copied every `Steps` row into the export body, even if
future call sites or malformed state provided blank date or value fields.

## Objectives

- Preserve the user-confirmed export flow.
- Keep the existing `date`/`value` payload shape.
- Trim and reject blank export row fields before POST.
- Skip network handling if row filtering leaves no valid payload rows.
- Extend docs and the static privacy baseline so row validation remains visible.

## Work Completed

- Added `validExportField(value:)` to trim and reject blank export fields.
- Made `exportPayload(steps:)` include only rows with valid date and value
  fields.
- Added a post-filter empty-payload guard before `postRequest(json)`.
- Updated README, SECURITY, VISION, CHANGES, and `scripts/check-baseline.sh`.

## Verification

- `sh -n scripts/check-baseline.sh`
- `scripts/check-baseline.sh`
- `make check`
- `make lint`
- `make test`
- `make build`
- `git diff --check`

Full app verification still requires macOS/Xcode and a HealthKit-capable device
with synthetic data.
