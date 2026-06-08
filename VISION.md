## Extract HealthKit Data Vision

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

Next priorities:

- Add README setup, permissions, and verification instructions
- Move the export endpoint into documented local configuration
- Modernize Swift, Alamofire, SwiftyJSON, and HealthKit APIs in a dedicated pass
- Add tests or manual verification notes for authorization and export behavior

Contribution rules:

- One PR = one focused HealthKit, export, build, or documentation change.
- Verify HealthKit behavior on a capable device when changing data access.
- Keep exported payload shape documented.
- Do not mix toolchain migration with privacy-sensitive behavior changes.

## Security And Privacy

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)


HealthKit step data is sensitive. The app should request only the data it needs,
make export behavior explicit, and avoid logging or committing health data.

Remote endpoint changes must use HTTPS and documented configuration.

## What We Will Not Merge (For Now)

- Hardcoded private endpoints or credentials
- Background health-data export without clear user action
- Broad Swift migration bundled with behavior changes
- Sample data copied from real HealthKit records

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
