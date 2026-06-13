# AGENTS.md

## Repository purpose

`garethpaul/extract-healthkit-data` is a legacy Swift iOS sample that reads step-count data from HealthKit, displays recent daily totals, and can export those values to a configured HTTPS endpoint.

## Project structure

- `Makefile` - repository verification targets
- `scripts` - baseline checks and helper scripts
- `docs` - plans, notes, and generated README assets
- `Podfile` - CocoaPods dependency definition
- `ExtractHealthKit.xcodeproj` - Xcode project
- `ExtractHealthKit.xcworkspace` - Xcode workspace
- `ExtractHealthKit` - repository source or sample assets
- `ExtractHealthKitTests` - repository source or sample assets

## Development commands

- Install dependencies: `pod install`
- Full baseline: `make check`
- Lint/static checks: `make lint`
- Tests: `make test`
- Build: `make build`
- Local Apple development: `open ExtractHealthKit.xcworkspace`
- If a command above skips because a platform toolchain is missing, verify on a machine with that SDK before claiming platform behavior is tested.

## Coding conventions

- Use the CocoaPods workspace when present; update `Podfile.lock` only with an intentional dependency change.
- Preserve legacy Xcode project settings and signing assumptions unless the change is explicitly about modernization.

## Testing guidance

- `ExtractHealthKitTests/ExtractHealthKitTests.swift` contains only template assertions; do not treat it as meaningful HealthKit or export coverage. The maintained regression gate is `make check`.
- Start with the narrowest relevant test or Make target, then run `make check` before handing off if the change is not documentation-only.
- Keep README verification notes in sync when commands, fixtures, or supported toolchains change.

## PR / change guidance

- Keep diffs focused on the requested repository and avoid unrelated modernization or formatting churn.
- Preserve public APIs, sample behavior, file formats, and documented environment variables unless the task explicitly changes them.
- Update tests, README notes, or docs/plans when behavior, security posture, or validation commands change.
- Call out skipped platform validation, legacy toolchain assumptions, and any risky files touched in the final summary.

## Safety and gotchas

- Keep endpoint URLs, API keys, OAuth credentials, tokens, signing material, and account-specific values in local configuration only.
- `HealthKitExportEndpoint` is the local HTTPS export endpoint setting. It must include a host and must not include embedded username/password userinfo, query strings, or fragments. Do not commit a private endpoint value.
- Provisioning profiles, signing certificates, certificate requests, app archives, and archive intermediates are ignored and must stay out of source control.
- Do not log, commit, or fixture real HealthKit records. Use synthetic data for verification notes and tests.
- Keep HealthKit authorization read-only and preserve the user confirmation before export. Authorization and query failures must use generic logs rather than raw HealthKit error descriptions.
- Export only non-empty rows with valid trimmed `date` and `value` fields, skip requests when no valid rows remain, inspect at most 30 rows, and reject encoded JSON larger than 64 KiB.
- The export body must remain a Foundation-valid JSON object, use `application/json`, and apply the 30-second request timeout before Alamofire queues the request.
- Hosted macOS CI proves the Xcode project parses, not that the app builds, signs, receives HealthKit authorization, or successfully exports from a device.
- Use `docs/manual-healthkit-verification.md` for physical-device verification. Keep its device, tester-owned data, controlled HTTPS endpoint, cancellation, request privacy, failure, and redacted-evidence requirements intact; do not mark it executed without a real Apple-platform run.
- This looks like an Apple platform project or sample. Xcode, Swift, CocoaPods, and deployment target versions may need to match the original project era.
- See `SECURITY.md` for vulnerability reporting and safe research guidance.

## Agent workflow

1. Inspect the README, Makefile, manifests, and the files directly related to the request.
2. Make the smallest source or docs change that satisfies the task; avoid generated, vendored, or local-environment files unless required.
3. Run the narrowest useful validation first, then `make check` or the documented package/platform gate when available.
4. If a required SDK, service credential, or external runtime is unavailable, record the skipped command and why.
5. Summarize changed files, commands run, and remaining risks or follow-up validation.
