# HealthKit JSON Payload Validation

status: completed

## Context

HealthKit exports are serialized with `NSJSONSerialization` before being sent to
the configured HTTPS endpoint. The payload helper currently builds arrays and
dictionaries, but `postRequest` is a public helper in the sample and should
reject unsupported payload shapes before attempting to serialize or send them.

## Objectives

- Preserve existing `date`/`value` export payload behavior.
- Reject payloads that are not valid Foundation JSON objects.
- Fail closed before creating the HTTP body or sending a request.
- Extend the static privacy baseline and docs so the serialization guard stays
  visible.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

Full app verification still requires macOS/Xcode and a HealthKit-capable device
with synthetic data.
