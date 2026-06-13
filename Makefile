.PHONY: build check lint test xcode-list

ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
XCODEBUILD ?= xcodebuild

check:
	@"$(ROOT)/scripts/check-baseline.sh"

lint: check

test: check

build: check

xcode-list:
	@$(XCODEBUILD) -list -project "$(ROOT)/ExtractHealthKit.xcodeproj"
