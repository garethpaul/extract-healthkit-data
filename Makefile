.PHONY: build check lint test xcode-list

override ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
XCODEBUILD ?= xcodebuild
SWIFTC ?= swiftc

check:
	@if command -v "$(SWIFTC)" >/dev/null 2>&1; then \
		SWIFTC="$(SWIFTC)" "$(ROOT)/scripts/run-healthkit-export-policy-tests.sh"; \
	else \
		echo "swiftc unavailable; executable HealthKit export policy tests skipped"; \
	fi
	@"$(ROOT)/scripts/check-baseline.sh"

lint: check

test: check

build: check

xcode-list:
	@$(XCODEBUILD) -list -project "$(ROOT)/ExtractHealthKit.xcodeproj"
