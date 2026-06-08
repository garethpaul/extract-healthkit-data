#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
README="$ROOT_DIR/README.md"
VISION="$ROOT_DIR/VISION.md"
PROJECT="$ROOT_DIR/ExtractHealthKit.xcodeproj/project.pbxproj"
API="$ROOT_DIR/ExtractHealthKit/API.swift"
VIEW="$ROOT_DIR/ExtractHealthKit/ViewController.swift"
PLAN="$ROOT_DIR/docs/plans/2026-06-08-extract-healthkit-privacy-baseline.md"

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
  "Podfile" \
  "Podfile.lock" \
  "ExtractHealthKit.xcodeproj/project.pbxproj" \
  "ExtractHealthKit/Info.plist" \
  "ExtractHealthKit/ExtractHealthKit.entitlements" \
  "ExtractHealthKit/API.swift" \
  "ExtractHealthKit/ViewController.swift" \
  "ExtractHealthKit/Steps.swift" \
  "docs/plans/2026-06-08-extract-healthkit-privacy-baseline.md"; do
  require_file "$path"
done

if ! grep -Fq "make check" "$README" ||
  ! grep -Fq "HealthKitExportEndpoint" "$README" ||
  ! grep -Fq "HealthKit step data is sensitive" "$README"; then
  printf '%s\n' "README must document verification, export configuration, and HealthKit privacy posture." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$VISION" ||
  ! grep -Fq "read-only HealthKit step-count access" "$VISION" ||
  ! grep -Fq "HealthKitExportEndpoint" "$VISION"; then
  printf '%s\n' "VISION must include the baseline command, read-only HealthKit scope, and endpoint configuration." >&2
  exit 1
fi

if grep -Fq "requestlabs.appspot.com" "$API" ||
  grep -Fq "println(json)" "$VIEW" ||
  grep -Fq "abort()" "$VIEW"; then
  printf '%s\n' "Health data export must not use hardcoded endpoints, payload logging, or abort-on-query-error." >&2
  exit 1
fi

if ! grep -Fq "HealthKitExportEndpointKey" "$API" ||
  ! grep -Fq "objectForInfoDictionaryKey" "$API" ||
  ! grep -Fq 'url?.scheme == "https"' "$API" ||
  ! grep -Fq "stringByTrimmingCharactersInSet" "$API" ||
  ! grep -Fq "return false" "$API"; then
  printf '%s\n' "API.swift must keep endpoint lookup, HTTPS validation, and failed-send return behavior." >&2
  exit 1
fi

if ! grep -Fq "requestAuthorizationToShareTypes(nil" "$VIEW" ||
  ! grep -Fq "readTypes: dataToRead" "$VIEW" ||
  ! grep -Fq "HealthKit export endpoint is not configured." "$VIEW"; then
  printf '%s\n' "ViewController must keep read-only HealthKit authorization and explicit export failure handling." >&2
  exit 1
fi

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

printf '%s\n' "extract-healthkit-data privacy baseline checks passed."
