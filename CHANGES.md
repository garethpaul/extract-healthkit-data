# Changes

## 2026-06-08

- Moved the HealthKit export endpoint to the `HealthKitExportEndpoint` app
  metadata key and require HTTPS before sending.
- Removed export payload logging and query-error `abort()` behavior.
- Requested read-only HealthKit step-count authorization.
- Added static privacy, entitlement, Podfile, plist, and source verification via
  `make check`.
