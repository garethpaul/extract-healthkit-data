## Extract HealthKit Data Vision

This document explains the current state and direction of the project.
Project overview and developer docs: [`README.md`](README.md)

Extract HealthKit Data is a Swift iOS sample that reads step-count data from
HealthKit, displays recent daily values, and can export those values to a remote
endpoint.

The repository is useful as a preserved HealthKit, table-view, Alamofire, and
SwiftyJSON example from an older Swift/CocoaPods stack.

The goal is to keep the HealthKit flow understandable while making health-data
privacy, endpoint configuration, and modernization work explicit.

The current focus is:

Priority:

- Preserve the HealthKit authorization and step-count query flow
- Keep export behavior visible and user-confirmed
- Avoid committing endpoint secrets, signing material, or health data
- Keep the CocoaPods workspace and iOS 8-era dependency assumptions clear

Current baseline:

- `scripts/check-baseline.sh` validates privacy-sensitive source invariants,
  HealthKit plist and entitlement metadata, locked CocoaPods versions, and Xcode
  project settings.
- The app requests read-only HealthKit step-count access.
- Export uses `HealthKitExportEndpoint` from app metadata, requires an HTTPS URL
  with a host and no embedded username/password userinfo, query string, or
  fragment, and does not log the step payload.
- Export builds an explicit `date`/`value` payload and skips the network request
  when no step rows are available.
- Export serialization only runs for Foundation-valid JSON objects.
- `.gitignore` and the static baseline keep local provisioning profiles,
  signing certificates, certificate requests, app archives, and archive
  intermediates out of source control.
- HealthKit query errors no longer abort the app.

Next priorities:

- Verify the privacy baseline on a macOS/Xcode machine with a HealthKit-capable
  device
- Modernize Swift, Alamofire, SwiftyJSON, and HealthKit APIs in a dedicated pass
- Add tests or manual verification notes for authorization and export behavior

Contribution rules:

- One PR = one focused HealthKit, export, build, or documentation change.
- Run `scripts/check-baseline.sh` before pushing HealthKit/export changes.
- Verify HealthKit behavior on a capable device when changing data access.
- Keep exported payload shape documented.
- Keep export payloads constrained to valid JSON objects before serialization.
- Keep empty or failed data reads from triggering export network calls.
- Keep signing material, provisioning profiles, and local archives untracked.
- Do not mix toolchain migration with privacy-sensitive behavior changes.

## Security And Privacy

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

HealthKit step data is sensitive. The app should request only the data it needs,
make export behavior explicit, and avoid logging or committing health data.

Remote endpoint changes must use HTTPS, include a host, avoid embedded
username/password userinfo, query strings, and fragments, and use documented
configuration.

## What We Will Not Merge (For Now)

- Hardcoded private endpoints or credentials
- Background health-data export without clear user action
- Broad Swift migration bundled with behavior changes
- Sample data copied from real HealthKit records

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
