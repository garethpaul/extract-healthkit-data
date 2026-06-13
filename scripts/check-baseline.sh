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
EXPORT_BOUNDS_PLAN="$ROOT_DIR/docs/plans/2026-06-10-healthkit-export-volume-bounds.md"
EXACT_SCOPE_PLAN="$ROOT_DIR/docs/plans/2026-06-12-healthkit-exact-30-day-scope.md"
CHECKOUT_CREDENTIAL_PLAN="$ROOT_DIR/docs/plans/2026-06-12-checkout-credential-boundary.md"
REQUEST_PRIVACY_PLAN="$ROOT_DIR/docs/plans/2026-06-13-healthkit-request-privacy.md"
MANUAL_VERIFICATION_PLAN="$ROOT_DIR/docs/plans/2026-06-13-healthkit-manual-verification.md"
SINGLE_PUBLICATION_PLAN="$ROOT_DIR/docs/plans/2026-06-13-healthkit-single-ui-publication.md"
LATEST_EXPORT_WINDOW_PLAN="$ROOT_DIR/docs/plans/2026-06-13-healthkit-latest-export-window.md"
MANUAL_VERIFICATION="$ROOT_DIR/docs/manual-healthkit-verification.md"
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
  "docs/manual-healthkit-verification.md" \
  "docs/plans/2026-06-09-healthkit-empty-export-guard.md" \
  "docs/plans/2026-06-09-healthkit-endpoint-userinfo-guard.md" \
  "docs/plans/2026-06-09-healthkit-endpoint-query-fragment-guard.md" \
  "docs/plans/2026-06-09-healthkit-signing-artifact-guard.md" \
  "docs/plans/2026-06-09-healthkit-json-payload-validation.md" \
  "docs/plans/2026-06-09-healthkit-error-logging-guard.md" \
  "docs/plans/2026-06-09-healthkit-export-row-validation.md" \
  "docs/plans/2026-06-09-healthkit-export-timeout.md" \
  "docs/plans/2026-06-10-healthkit-ci-baseline.md" \
  "docs/plans/2026-06-10-healthkit-export-volume-bounds.md" \
  "docs/plans/2026-06-12-healthkit-exact-30-day-scope.md" \
  "docs/plans/2026-06-12-checkout-credential-boundary.md" \
  "docs/plans/2026-06-13-healthkit-request-privacy.md" \
  "docs/plans/2026-06-13-healthkit-manual-verification.md" \
  "docs/plans/2026-06-13-healthkit-single-ui-publication.md" \
  "docs/plans/2026-06-13-healthkit-latest-export-window.md" \
  "docs/plans/2026-06-08-healthkit-endpoint-host-validation.md" \
  "docs/plans/2026-06-08-extract-healthkit-privacy-baseline.md"; do
  require_file "$path"
done

python3 - "$VIEW" <<'PY'
import pathlib
import sys

source = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
sort_array = source.split("    func sortArray()", 1)[1].split("    func tableView", 1)[0]
query_handler = source.split("        query.initialResultsHandler =", 1)[1].split(
    "        theHealthStore.executeQuery(query)", 1
)[0]

dispatch = "dispatch_async(dispatch_get_main_queue()"
assignment = "self.tableData = self.outData.reverse()"
reload = "self.tableView.reloadData()"
if any(sort_array.count(contract) != 1 for contract in (dispatch, assignment, reload)):
    raise SystemExit("HealthKit UI publication calls must remain unique in sortArray.")
if not sort_array.index(dispatch) < sort_array.index(assignment) < sort_array.index(reload):
    raise SystemExit("HealthKit table data and reload must publish together on the main queue.")
if "tableData = outData.reverse()" in sort_array:
    raise SystemExit("HealthKit table data must not mutate before the main-queue block.")
if query_handler.count("self.sortArray()") != 1:
    raise SystemExit("HealthKit query results must publish exactly once.")
if "            }\n\n            self.sortArray()" not in query_handler:
    raise SystemExit("HealthKit query results must publish after statistics enumeration completes.")
PY

if ! grep -Fq "status: completed" "$SINGLE_PUBLICATION_PLAN" ||
  ! grep -Fq "hostile mutations were rejected" "$SINGLE_PUBLICATION_PLAN" ||
  ! grep -Fq "not performed locally" "$SINGLE_PUBLICATION_PLAN" ||
  ! grep -Fq "hosted macOS" "$SINGLE_PUBLICATION_PLAN"; then
  printf '%s\n' "HealthKit single-publication plan must record truthful completed evidence." >&2
  exit 1
fi

if ! grep -Fq "statistics are published to the table once" "$README" ||
  ! grep -Fq "table together on the main queue" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "publish one complete table snapshot" "$VISION" ||
  ! grep -Fq "Published each completed HealthKit statistics result" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Project docs must preserve the HealthKit single-publication boundary." >&2
  exit 1
fi

workflow_count=$(find "$ROOT_DIR/.github/workflows" -type f \( -name '*.yml' -o -name '*.yaml' \) | wc -l | tr -d ' ')
checkout_count=$(grep -Ec '^[[:space:]]*-[[:space:]]*uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10' "$CI_WORKFLOW" || true)
credential_boundary_count=$(grep -Ec '^[[:space:]]*persist-credentials:[[:space:]]*false([[:space:]]|$)' "$CI_WORKFLOW" || true)
if [ "$workflow_count" -ne 1 ] || [ "$checkout_count" -ne 1 ] || [ "$credential_boundary_count" -ne 1 ]; then
  printf '%s\n' "GitHub Actions must keep one workflow with one pinned, credential-free checkout." >&2
  exit 1
fi

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
  ! grep -Fq "exact 30-day lookback" "$README" ||
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
  ! grep -Fq "exact 30-day limit" "$VISION" ||
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

if ! grep -Fq "exact 30-day limit" "$ROOT_DIR/SECURITY.md"; then
  printf '%s\n' "SECURITY must document the exact HealthKit collection and export boundary." >&2
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
  ! grep -Fq "HealthKitExportMaxPayloadBytes" "$API" ||
  ! grep -Fq "encodedBody.length > HealthKitExportMaxPayloadBytes" "$API" ||
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

if [ "$(grep -Fc 'request.HTTPShouldHandleCookies = false' "$API")" -ne 1 ] ||
  [ "$(grep -Fc 'request.setValue("no-store", forHTTPHeaderField: "Cache-Control")' "$API")" -ne 1 ]; then
  printf '%s\n' "HealthKit export requests must disable cookies and set Cache-Control: no-store exactly once." >&2
  exit 1
fi

if ! grep -Fq "requestAuthorizationToShareTypes(nil" "$VIEW" ||
  ! grep -Fq "readTypes: dataToRead" "$VIEW" ||
  ! grep -Fq "func exportPayload(steps: [Steps]) -> [AnyObject]" "$VIEW" ||
  ! grep -Fq "HealthKitExportLookbackDays = 30" "$VIEW" ||
  ! grep -Fq "inspectedRows >= HealthKitExportLookbackDays" "$VIEW" ||
  ! grep -Fq "dateByAddingUnit(.CalendarUnitDay, value: -HealthKitExportLookbackDays" "$VIEW" ||
  grep -Fq "dateByAddingUnit(.CalendarUnitMonth, value: -1" "$VIEW" ||
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

python3 - "$API" "$VIEW" <<'PY'
import sys
from pathlib import Path

api = Path(sys.argv[1]).read_text(encoding="utf-8")
view = Path(sys.argv[2]).read_text(encoding="utf-8")

payload_limit = api.find("encodedBody.length > HealthKitExportMaxPayloadBytes")
body_assignment = api.find("request.HTTPBody = encodedBody")
request_start = api.find("Alamofire.request(request)")
if -1 in (payload_limit, body_assignment, request_start) or not (
    payload_limit < body_assignment < request_start
):
    print("HealthKit payload size must be checked before assigning or sending the request body.", file=sys.stderr)
    raise SystemExit(1)

cookie_isolation = api.find("request.HTTPShouldHandleCookies = false")
cache_control = api.find('request.setValue("no-store", forHTTPHeaderField: "Cache-Control")')
json_validation = api.find("NSJSONSerialization.isValidJSONObject(payload)")
if -1 in (cookie_isolation, cache_control, json_validation, request_start) or not (
    cookie_isolation < json_validation
    and cache_control < json_validation
    and json_validation < request_start
):
    print("HealthKit request cookie and cache protections must precede serialization and dispatch.", file=sys.stderr)
    raise SystemExit(1)

latest_first = view.find("for item in steps.reverse()")
row_limit = view.find("inspectedRows >= HealthKitExportLookbackDays")
query_limit = view.find("dateByAddingUnit(.CalendarUnitDay, value: -HealthKitExportLookbackDays")
field_validation = view.find("if let date = validExportField(item.date)")
payload_append = view.find('json.append(["date": date, "value": value])')
chronological_return = view.find("return json.reverse()")
if -1 in (latest_first, row_limit, query_limit, field_validation, payload_append, chronological_return) or not (
    latest_first < row_limit < field_validation < payload_append < chronological_return
):
    print("HealthKit export must select the newest bounded window and restore chronological order.", file=sys.stderr)
    raise SystemExit(1)

if view.count("for item in steps.reverse()") != 1 or view.count("return json.reverse()") != 1:
    print("HealthKit latest-window ordering contracts must remain unique.", file=sys.stderr)
    raise SystemExit(1)

fixture = ["day-%02d" % index for index in range(31)]
selected = list(reversed(fixture))[:30]
payload = list(reversed(selected))
if payload != fixture[1:] or fixture[0] in payload or fixture[-1] not in payload:
    print("HealthKit 31-bucket latest-window fixture failed.", file=sys.stderr)
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

if ! grep -Fq "Status: Completed" "$CHECKOUT_CREDENTIAL_PLAN" ||
  ! grep -Fq "make check" "$CHECKOUT_CREDENTIAL_PLAN"; then
  printf '%s\n' "Checkout credential boundary plan must record completed make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$EXPORT_BOUNDS_PLAN" ||
  ! grep -Fq "make check" "$EXPORT_BOUNDS_PLAN"; then
  printf '%s\n' "HealthKit export volume plan must remain completed with verification recorded." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$EXACT_SCOPE_PLAN" ||
  ! grep -Fq "27391707339" "$EXACT_SCOPE_PLAN" ||
  ! grep -Fq "27391708457" "$EXACT_SCOPE_PLAN"; then
  printf '%s\n' "Exact 30-day scope plan must remain completed with hosted verification recorded." >&2
  exit 1
fi

for latest_window_contract in \
  "status: completed" \
  "## Status: Completed" \
  "focused latest-window source and 31-bucket fixture contract passed" \
  "make build" \
  "Six isolated hostile mutations were rejected" \
  "live HTTPS export were unavailable and are not claimed"; do
  if ! grep -Fq "$latest_window_contract" "$LATEST_EXPORT_WINDOW_PLAN"; then
    printf '%s\n' "Latest HealthKit export-window plan must record completed verification: $latest_window_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "selects the newest 30 daily buckets" "$README" ||
  ! grep -Fq "newest 30 daily buckets while preserving" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "selecting the newest 30 daily buckets" "$VISION" ||
  ! grep -Fq "Selected the newest 30 collected HealthKit daily buckets" "$ROOT_DIR/CHANGES.md" ||
  ! grep -Fq "select the newest 30 daily buckets" "$ROOT_DIR/AGENTS.md"; then
  printf '%s\n' "Latest HealthKit export-window documentation must remain synchronized." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$REQUEST_PRIVACY_PLAN" ||
  ! grep -Fq "cookie isolation mutation failed" "$REQUEST_PRIVACY_PLAN" ||
  ! grep -Fq "no-store mutation failed" "$REQUEST_PRIVACY_PLAN" ||
  ! grep -Fq "ordering mutation failed" "$REQUEST_PRIVACY_PLAN" ||
  ! grep -Fq "hosted macOS check" "$REQUEST_PRIVACY_PLAN"; then
  printf '%s\n' "HealthKit request privacy plan must record completed local verification." >&2
  exit 1
fi

if ! grep -Fq "disables shared HTTP cookie handling" "$README" ||
  ! grep -Fq "disable cookie handling and declare Cache-Control: no-store" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "Request cookie handling is disabled and export bodies are marked no-store" "$VISION" ||
  ! grep -Fq "Disabled cookie handling and added Cache-Control: no-store" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Project guidance must document HealthKit request privacy isolation." >&2
  exit 1
fi

python3 - "$MANUAL_VERIFICATION" <<'PY'
import sys
from pathlib import Path

source = Path(sys.argv[1]).read_text(encoding="utf-8")
required_sections = {
    "Status And Scope": [
        "was not executed during the Linux maintenance session",
        "Static Linux checks and hosted Xcode project parsing do not satisfy this run.",
        "synthetic data or HealthKit records owned by the tester",
    ],
    "Prerequisites": [
        "HealthKit-capable physical iPhone",
        "simulator is not sufficient",
        "controlled HTTPS endpoint owned by the tester",
        "Never commit the configured endpoint.",
    ],
    "Authorization And Query": [
        "read-only access to step count",
        "does not request write access or unrelated HealthKit data",
        "Deny step-count access",
        "exact 30-day lookback",
    ],
    "Confirmation And Export": [
        "last 30 days will be sent",
        "Cancel the alert",
        "exactly one POST",
        "contains no credentials or unexpected health fields",
        "64 KiB encoded-body limit",
    ],
    "Privacy And Failure Checks": [
        "Content-Type: application/json",
        "Cache-Control: no-store",
        "no `Cookie` header",
        "HealthKit export endpoint is not configured",
        "does not log the request body, raw health records, credentials, or endpoint secrets",
    ],
    "Evidence Record": [
        "commit SHA",
        "physical device model",
        "scrubbed of health data, endpoint values, credentials, device identifiers, and signing details",
        "not proof of HealthKit authorization",
    ],
}

sections = {}
current = None
for line in source.splitlines():
    if line.startswith("## "):
        current = line[3:]
        sections[current] = []
    elif current is not None:
        sections[current].append(line)

for heading, phrases in required_sections.items():
    body = "\n".join(sections.get(heading, []))
    if not body:
        raise SystemExit("Manual HealthKit checklist section missing: " + heading)
    normalized_body = " ".join(body.split())
    for phrase in phrases:
        if " ".join(phrase.split()) not in normalized_body:
            raise SystemExit(
                "Manual HealthKit checklist assertion missing from "
                + heading
                + ": "
                + phrase
            )
PY

if ! grep -Fq "status: completed" "$MANUAL_VERIFICATION_PLAN" ||
  ! grep -Fq "hostile mutations were rejected" "$MANUAL_VERIFICATION_PLAN" ||
  ! grep -Fq "physical-device checklist" "$MANUAL_VERIFICATION_PLAN" ||
  ! grep -Fq "hosted macOS check" "$MANUAL_VERIFICATION_PLAN"; then
  printf '%s\n' "HealthKit manual verification plan must record completed local verification." >&2
  exit 1
fi

if ! grep -Fq "physical-device checklist" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "checklist remains unexecuted" "$ROOT_DIR/CHANGES.md" ||
  ! grep -Fq "without claiming that the checklist has been executed" "$VISION" ||
  grep -Fq "Add tests or manual verification notes for authorization and export behavior" "$VISION" ||
  ! grep -Fq "docs/manual-healthkit-verification.md" "$README" ||
  ! grep -Fq "docs/manual-healthkit-verification.md" "$ROOT_DIR/AGENTS.md"; then
  printf '%s\n' "Project guidance must preserve truthful HealthKit manual verification boundaries." >&2
  exit 1
fi

printf '%s\n' "extract-healthkit-data privacy baseline checks passed."
