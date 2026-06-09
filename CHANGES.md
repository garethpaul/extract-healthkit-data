# Changes

## 2026-06-09

- Rejected HealthKit export endpoints with embedded username/password userinfo.
- Extracted HealthKit export payload construction into a dedicated helper.
- Skipped export network requests when no step rows are available.
- Added a static baseline guard and plan for the empty-export behavior.

## 2026-06-08

- Moved the HealthKit export endpoint to the `HealthKitExportEndpoint` app
  metadata key and require HTTPS before sending.
- Require configured export endpoints to include a non-empty host before
  sending HealthKit payloads.
- Removed export payload logging and query-error `abort()` behavior.
- Requested read-only HealthKit step-count authorization.
- Added static privacy, entitlement, Podfile, plist, and source verification via
  `make check`.
