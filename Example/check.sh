#!/bin/zsh
# Builds HitTestCheck in Release and runs its hit test check on one iPhone simulator per installed iOS runtime.
set -euo pipefail
cd "${0:a:h}"

xcodebuild build -project HitTestCheck.xcodeproj -scheme HitTestCheck -configuration Release \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath .build -quiet
app=.build/Build/Products/Release-iphonesimulator/HitTestCheck.app
bundle_id=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$app/Info.plist")

# First available iPhone of each iOS runtime.
devices=$(xcrun simctl list devices available -j | python3 -c '
import json, sys
for runtime, devices in json.load(sys.stdin)["devices"].items():
    if "iOS" in runtime:
        iphones = [d for d in devices if "iPhone" in d.get("deviceTypeIdentifier", "")]
        if iphones:
            print(iphones[0]["udid"])
')

failed=0
for udid in ${(f)devices}; do
  xcrun simctl boot "$udid" 2>/dev/null || true
  xcrun simctl bootstatus "$udid" -b >/dev/null
  xcrun simctl install "$udid" "$app"
  output=$(xcrun simctl launch --console-pty --terminate-running-process "$udid" "$bundle_id" -check 2>&1 | grep CHECK || true)
  echo "$output"
  if [[ -z "$output" || "$output" == *FAIL* ]]; then failed=1; fi
done
exit $failed
