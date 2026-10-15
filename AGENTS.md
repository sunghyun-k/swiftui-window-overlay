# AGENTS.md

Guidance for agents working in this repository.

## Overview

A SwiftUI modifier, `windowOverlay(isPresented:disableSafeArea:content:)`, that renders content in a separate `UIWindow` above the app's window. That one modifier is the whole public API.

- `WindowOverlayModifier.swift`: the public modifier.
- `Internals/WindowBridgingView.swift`: a background view that creates, updates and tears down the overlay window for its window scene.
- `Internals/WindowOverlayWindow.swift`: the overlay window (just below system alerts) and its hit test.
- `Internals/StatusBarForwardingHostingController.swift`: keeps the app window in control of the status bar.

## Build

The package is iOS only, so `swift build` (macOS) doesn't work. Build in both language modes:

```bash
for v in 5 6; do
  xcodebuild build -scheme swiftui-window-overlay -destination 'generic/platform=iOS Simulator' SWIFT_VERSION=$v -quiet 2>&1 | grep -E "error:|warning:"
done
```

## Rules

- Don't add package dependencies.
- The deployment target is iOS 13. Guard newer APIs with `#available` instead of raising it.
- Keep the public API source compatible. A breaking change needs a major version.
- Keep everything except the modifier `internal`.
- Use two-space indentation, matching the existing code.
- The README is for people using the package: API, behavior and workarounds. Implementation notes go here.

## Hit testing

Touches pass through wherever the overlay draws nothing. `WindowOverlayWindow.hitTest` decides this by looking at how SwiftUI builds its views, which is undocumented and changes between OS versions:

- UIKit-backed controls (`TextField`, `Toggle`, `ScrollView`) and, before iOS 26, everything SwiftUI draws are subviews of the hosting view.
- From iOS 26, drawn content is layers under the hosting view's layer, so `layer.hitTest(_:)` returns something other than the hosting view's own layer.

Don't go back to sampling pixel alpha: it misses materials and renders on every touch.

Any change to the hit test needs checking on every iOS runtime you can install, in a Release build. There's no test target because the check needs a running app. Build a small app that shows an overlay with the cases below, calls the overlay window's `hitTest(_:with:)` at each point, and prints the results:

| Content | Expected |
|---|---|
| `Button`, text on `.ultraThinMaterial`, an opaque color | takes the touch |
| `Toggle`, `ScrollView`, `TextField` | takes the touch |
| `Color.black.opacity(0.001)` | takes the touch |
| `.glassEffect()`, `.buttonStyle(.glass)` (iOS 26+) | takes the touch |
| `.allowsHitTesting(false)` content, empty space | passes through |
| `Color.clear.contentShape(Rectangle())` | passes through (known limitation) |

After dismissing, check that the overlay window is hidden and its `rootViewController` is `nil`.
