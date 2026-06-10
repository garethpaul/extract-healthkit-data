#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
README="$ROOT_DIR/README.md"
VISION="$ROOT_DIR/VISION.md"
PROJECT="$ROOT_DIR/ExtractHealthKit.xcodeproj/project.pbxproj"
API="$ROOT_DIR/ExtractHealthKit/API.swift"
VIEW="$ROOT_DIR/ExtractHealthKit/ViewController.swift"
PLAN="$ROOT_DIR/docs/plans/2026-06-08-extract-healthkit-privacy-baseline.md"
ENDPOINT_PLAN="$ROOT_DIR/docs/plans/2026-06-08-healthkit-endpoint-host-validation.md"
EMPTY_EXPORT_PLAN="$ROOT_DIR/docs/plans/2026-06-09-healthkit-empty-export-guard.md"
USERINFO_PLAN="$ROOT_DIR/docs/plans/2026-06-09-healthkit-endpoint-userinfo-guard.md"
URL_PARTS_PLAN="$ROOT_DIR/docs/plans/2026-06-09-healthkit-endpoint-query-fragment-guard.md"
SIGNING_PLAN="$ROOT_DIR/docs/plans/2026-06-09-healthkit-signing-artifact-guard.md"
JSON_PAYLOAD_PLAN="$ROOT_DIR/docs/plans/2026-06-09-healthkit-json-payload-validation.md"
ERROR_LOGGING_PLAN="$ROOT_DIR/docs/plans/2026-06-09-healthkit-error-logging-guard.md"
EXPORT_ROW_PLAN="$ROOT_DIR/docs/plans/2026-06-09-healthkit-export-row-validation.md"
EXPORT_TIMEOUT_PLAN="$ROOT_DIR/docs/plans/2026-06-09-healthkit-export-timeout.md"
CI_PLAN="$ROOT_DIR/docs/plans/2026-06-10-healthkit-ci-baseline.md"
CI_WORKFLOW="$ROOT_DIR/.github/workflows/check.yml"

require_file() {
  path=$1
  if [ ! -f "$ROOT_DIR/$path" ]; then
    printf '%s\n' "Required file missing: $path" >&2
    exit 1
  fi
}

for path in \
  ".gitignore" \
  "CHANGES.md" \
  "Makefile" \
  "README.md" \
  "SECURITY.md" \
  "VISION.md" \
  ".github/workflows/check.yml" \
  "Podfile" \
  "Podfile.lock" \
  "ExtractHealthKit.xcodeproj/project.pbxproj" \
  "ExtractHealthKit/Info.plist" \
  "ExtractHealthKit/ExtractHealthKit.entitlements" \
  "ExtractHealthKit/API.swift" \
  "ExtractHealthKit/ViewController.swift" \
  "ExtractHealthKit/Steps.swift" \
  "docs/plans/2026-06-09-healthkit-empty-export-guard.md" \
  "docs/plans/2026-06-09-healthkit-endpoint-userinfo-guard.md" \
  "docs/plans/2026-06-09-healthkit-endpoint-query-fragment-guard.md" \
  "docs/plans/2026-06-09-healthkit-signing-artifact-guard.md" \
  "docs/plans/2026-06-09-healthkit-json-payload-validation.md" \
  "docs/plans/2026-06-09-healthkit-error-logging-guard.md" \
  "docs/plans/2026-06-09-healthkit-export-row-validation.md" \
  "docs/plans/2026-06-09-healthkit-export-timeout.md" \
  "docs/plans/2026-06-10-healthkit-ci-baseline.md" \
  "docs/plans/2026-06-08-healthkit-endpoint-host-validation.md" \
  "docs/plans/2026-06-08-extract-healthkit-privacy-baseline.md"; do
  require_file "$path"
done

for workflow_contract in \
  "runs-on: macos-15" \
  "permissions:" \
  "contents: read" \
  "workflow_dispatch:" \
  "cancel-in-progress: true" \
  "timeout-minutes: 10" \
  "actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10" \
  "run: make check"; do
  if ! grep -Fq "$workflow_contract" "$CI_WORKFLOW"; then
    printf '%s\n' "GitHub Actions HealthKit baseline is missing: $workflow_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "make check" "$README" ||
  ! grep -Fq "HealthKitExportEndpoint" "$README" ||
  ! grep -Fq "includes a host" "$README" ||
  ! grep -Fq "query strings, or fragments" "$README" ||
  ! grep -Fq "valid JSON objects" "$README" ||
  ! grep -Fq "valid date/value fields" "$README" ||
  ! grep -Fq "bounded timeout" "$README" ||
  ! grep -Fq "raw HealthKit error descriptions" "$README" ||
  ! grep -Fq "HealthKit step data is sensitive" "$README"; then
  printf '%s\n' "README must document verification, export configuration, and HealthKit privacy posture." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$VISION" ||
  ! grep -Fq "read-only HealthKit step-count access" "$VISION" ||
  ! grep -Fq "HTTPS URL" "$VISION" ||
  ! grep -Fq "query string, or" "$VISION" ||
  ! grep -Fq "valid JSON objects" "$VISION" ||
  ! grep -Fq "valid date/value fields" "$VISION" ||
  ! grep -Fq "bounded timeout" "$VISION" ||
  ! grep -Fq "HealthKit failure logging" "$VISION" ||
  ! grep -Fq "HealthKitExportEndpoint" "$VISION"; then
  printf '%s\n' "VISION must include the baseline command, read-only HealthKit scope, and endpoint configuration." >&2
  exit 1
fi

if grep -Fq "requestlabs.appspot.com" "$API" ||
  grep -Fq "println(json)" "$VIEW" ||
  grep -Fq "error.description" "$VIEW" ||
  grep -Fq "error.localizedDescription" "$VIEW" ||
  grep -Fq "abort()" "$VIEW"; then
  printf '%s\n' "Health data export must not use hardcoded endpoints, payload logging, or abort-on-query-error." >&2
  exit 1
fi

if ! grep -Fq "raw HealthKit error" "$ROOT_DIR/SECURITY.md"; then
  printf '%s\n' "SECURITY must document HealthKit error logging boundaries." >&2
  exit 1
fi

if ! grep -Fq "valid date/value fields" "$ROOT_DIR/SECURITY.md"; then
  printf '%s\n' "SECURITY must document HealthKit export row validation." >&2
  exit 1
fi

if ! grep -Fq "bounded timeout" "$ROOT_DIR/SECURITY.md"; then
  printf '%s\n' "SECURITY must document HealthKit export request timeout handling." >&2
  exit 1
fi

if ! grep -Fq "HealthKitExportEndpointKey" "$API" ||
  ! grep -Fq "HealthKitExportTimeout" "$API" ||
  ! grep -Fq "request.timeoutInterval = HealthKitExportTimeout" "$API" ||
  ! grep -Fq "objectForInfoDictionaryKey" "$API" ||
  ! grep -Fq 'url?.scheme == "https"' "$API" ||
  ! grep -Fq "url?.user == nil" "$API" ||
  ! grep -Fq "url?.password == nil" "$API" ||
  ! grep -Fq "url?.query == nil" "$API" ||
  ! grep -Fq "url?.fragment == nil" "$API" ||
  ! grep -Fq "if let host = url?.host" "$API" ||
  ! grep -Fq "!host.isEmpty" "$API" ||
  ! grep -Fq "stringByTrimmingCharactersInSet" "$API" ||
  ! grep -Fq "NSJSONSerialization.isValidJSONObject(payload)" "$API" ||
  ! grep -Fq "return false" "$API"; then
  printf '%s\n' "API.swift must keep endpoint lookup, HTTPS host validation, and failed-send return behavior." >&2
  exit 1
fi

if ! grep -Fq "requestAuthorizationToShareTypes(nil" "$VIEW" ||
  ! grep -Fq "readTypes: dataToRead" "$VIEW" ||
  ! grep -Fq "func exportPayload(steps: [Steps]) -> [AnyObject]" "$VIEW" ||
  ! grep -Fq "func validExportField(value: String) -> String?" "$VIEW" ||
  ! grep -Fq "stringByTrimmingCharactersInSet" "$VIEW" ||
  ! grep -Fq "self.outData.isEmpty" "$VIEW" ||
  ! grep -Fq "No HealthKit step data available to export." "$VIEW" ||
  ! grep -Fq "let json = exportPayload(self.outData)" "$VIEW" ||
  ! grep -Fq "json.isEmpty" "$VIEW" ||
  ! grep -Fq "No valid HealthKit step data available to export." "$VIEW" ||
  ! grep -Fq "HealthKit authorization was not granted." "$VIEW" ||
  ! grep -Fq "HealthKit statistics query failed." "$VIEW" ||
  ! grep -Fq "HealthKit export endpoint is not configured." "$VIEW"; then
  printf '%s\n' "ViewController must keep read-only HealthKit authorization and explicit export failure handling." >&2
  exit 1
fi

for pattern in \
  "*.mobileprovision" \
  "*.provisionprofile" \
  "*.p12" \
  "*.cer" \
  "*.certSigningRequest" \
  "*.xcarchive/" \
  "ArchiveIntermediates/"; do
  if ! grep -Fq "$pattern" "$ROOT_DIR/.gitignore"; then
    printf '%s\n' ".gitignore must keep signing and archive artifact pattern: $pattern" >&2
    exit 1
  fi
done

tracked_signing_artifacts=$(git -C "$ROOT_DIR" ls-files | grep -E '(^|/)([^/]+\.(mobileprovision|provisionprofile|p12|cer|certSigningRequest)|[^/]+\.xcarchive(/|$)|ArchiveIntermediates(/|$))' || true)
if [ -n "$tracked_signing_artifacts" ]; then
  printf '%s\n' "Signing or local archive artifacts must not be tracked:" >&2
  printf '%s\n' "$tracked_signing_artifacts" >&2
  exit 1
fi

python3 - "$VIEW" <<'PY'
import sys
from pathlib import Path

source = Path(sys.argv[1]).read_text(encoding="utf-8")
empty_guard = source.find("self.outData.isEmpty")
payload = source.find("let json = exportPayload(self.outData)")
filtered_guard = source.find("json.isEmpty")
post = source.find("postRequest(json)")
if -1 in (empty_guard, payload, filtered_guard, post) or not (empty_guard < payload < filtered_guard < post):
    print("HealthKit export must guard empty data before building, filter invalid rows, then post the payload.", file=sys.stderr)
    raise SystemExit(1)
PY

if ! grep -Fq "com.apple.developer.healthkit" "$ROOT_DIR/ExtractHealthKit/ExtractHealthKit.entitlements" ||
  ! grep -Fq "IPHONEOS_DEPLOYMENT_TARGET = 8.3;" "$PROJECT" ||
  ! grep -Fq "Alamofire (1.2.2)" "$ROOT_DIR/Podfile.lock" ||
  ! grep -Fq "SwiftyJSON (2.2.0)" "$ROOT_DIR/Podfile.lock"; then
  printf '%s\n' "Entitlement, deployment target, and locked CocoaPods versions must remain explicit." >&2
  exit 1
fi

python3 - "$ROOT_DIR" <<'PY'
import plistlib
import sys
from pathlib import Path

root = Path(sys.argv[1])

def fail(message):
    print(message, file=sys.stderr)
    raise SystemExit(1)

with (root / "ExtractHealthKit/Info.plist").open("rb") as fh:
    app_plist = plistlib.load(fh)

if "healthkit" not in app_plist.get("UIRequiredDeviceCapabilities", []):
    fail("Info.plist must keep HealthKit as a required device capability.")
if app_plist.get("HealthKitExportEndpoint") != "":
    fail("HealthKitExportEndpoint must stay empty in the committed plist.")
if not app_plist.get("NSHealthShareUsageDescription"):
    fail("Info.plist must include a HealthKit read usage description.")
if not app_plist.get("NSHealthUpdateUsageDescription"):
    fail("Info.plist must include a HealthKit write usage description boundary.")
PY

if command -v xcodebuild >/dev/null 2>&1; then
  xcodebuild -list -project "$ROOT_DIR/ExtractHealthKit.xcodeproj" >/dev/null
else
  printf '%s\n' "Skipping xcodebuild project parse: xcodebuild is not installed."
fi

if ! grep -Fq "status: completed" "$PLAN"; then
  printf '%s\n' "Plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$ENDPOINT_PLAN"; then
  printf '%s\n' "Endpoint host validation plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$EMPTY_EXPORT_PLAN"; then
  printf '%s\n' "Empty export guard plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$USERINFO_PLAN"; then
  printf '%s\n' "Endpoint userinfo guard plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$URL_PARTS_PLAN"; then
  printf '%s\n' "Endpoint query/fragment guard plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$SIGNING_PLAN"; then
  printf '%s\n' "Signing artifact guard plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$JSON_PAYLOAD_PLAN"; then
  printf '%s\n' "JSON payload validation plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$ERROR_LOGGING_PLAN"; then
  printf '%s\n' "HealthKit error logging guard plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$EXPORT_ROW_PLAN"; then
  printf '%s\n' "HealthKit export row validation plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$EXPORT_TIMEOUT_PLAN"; then
  printf '%s\n' "HealthKit export timeout plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ERROR_LOGGING_PLAN"; then
  printf '%s\n' "HealthKit error logging guard plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "make check" "$EXPORT_ROW_PLAN"; then
  printf '%s\n' "HealthKit export row validation plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "make check" "$EXPORT_TIMEOUT_PLAN"; then
  printf '%s\n' "HealthKit export timeout plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$CI_PLAN" ||
  ! grep -Fq "xcodebuild -list" "$CI_PLAN" ||
  ! grep -Fq "make check" "$CI_PLAN"; then
  printf '%s\n' "HealthKit CI plan must remain completed with hosted Xcode verification recorded." >&2
  exit 1
fi

printf '%s\n' "extract-healthkit-data privacy baseline checks passed."
