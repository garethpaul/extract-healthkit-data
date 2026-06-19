# HealthKit Manual Verification

Use this checklist on a HealthKit-capable physical device before claiming that
authorization, step queries, confirmation, or export behavior works at runtime.

## Status And Scope

This checklist is defined but was not executed during the Linux maintenance
session that added it. Record a separate result for each tested commit and do
not convert a project-parse result into device-runtime evidence. Static Linux
checks and hosted Xcode project parsing do not satisfy this run.

Use only synthetic data or HealthKit records owned by the tester. Do not attach
raw health records, private endpoint values, credentials, signing material, or
unredacted request bodies to an issue or pull request.

## Prerequisites

- A compatible macOS and Xcode version for this legacy Swift project.
- The CocoaPods workspace opened after a successful local `pod install`.
- Valid local signing for a HealthKit-capable physical iPhone; a simulator is
  not sufficient for this checklist.
- Tester-owned step-count data covering populated and empty-result cases.
- A controlled HTTPS endpoint owned by the tester that can inspect one request
  and securely delete captured data afterward.
- A local `HealthKitExportEndpoint` value with no credentials, userinfo, query,
  or fragment. Never commit the configured endpoint.

## Authorization And Query

1. Build and run the app from `ExtractHealthKit.xcworkspace` at the exact commit
   being verified.
2. Confirm the authorization sheet requests read-only access to step count and
   does not request write access or unrelated HealthKit data.
3. Deny step-count access. Confirm the app remains responsive, exports nothing,
   and exposes no raw HealthKit error description or record in device logs.
4. Grant step-count read access and relaunch. Confirm recent daily totals render
   for tester-owned data and the empty-result case remains usable.
5. Confirm the displayed/query scope is limited to the documented exact 30-day
   lookback; record any date-boundary discrepancy without capturing health data.

## Confirmation And Export

1. Start export with populated tester-owned data and confirm the alert states
   that the last 30 days will be sent.
2. Cancel the alert and verify that the controlled endpoint receives no request.
3. Start export again, explicitly confirm, and verify exactly one POST reaches
   the controlled HTTPS endpoint.
4. Verify the JSON contains only trimmed `date` and `value` fields from at most
   30 inspected daily rows, contains no credentials or unexpected health fields,
   and remains within the documented 64 KiB encoded-body limit.
5. Repeat with no valid rows and confirm no network request is sent.

## Privacy And Failure Checks

- Inspect the confirmed request and verify `Content-Type: application/json`,
  `Cache-Control: no-store`, and no `Cookie` header.
- Remove the local endpoint configuration and confirm the app reports that the
  HealthKit export request was not queued without exposing a private value.
- Return a transport-error-free HTTP 2xx response and confirm the app reports
  completion only after that response arrives.
- Return a controlled non-2xx response, then exercise a transport failure;
  confirm both report generic failure while the app remains responsive and does
  not log the request body, raw health records, credentials, or endpoint secrets.
  Confirm diagnostics also omit the response body, status text, and raw error.
- Exercise denied authorization and a query failure where the test environment
  permits it; verify generic failure logs and no export request.
- Clean up captured endpoint data, local endpoint configuration, derived logs,
  and screenshots after recording a redacted result.

## Evidence Record

Record the commit SHA, macOS and Xcode versions, iOS version, physical device
model, CocoaPods result, whether the endpoint was tester-controlled, and a
pass/fail result for every checklist item. Note skipped or blocked steps with the
exact reason. Screenshots and logs must be scrubbed of health data, endpoint
values, credentials, device identifiers, and signing details.

Keep static evidence separate: record `make check` and hosted Xcode project
parsing as source/project validation, not proof of HealthKit authorization,
device queries, confirmation handling, or network export behavior.
