# WindowOverlay
WindowOverlay is a Swift package that provides a convenient way to add overlay views to your SwiftUI application's window. The overlay lives in its own window, so it stays above sheets, full screen covers and the keyboard.

## Features
- Easy integration with SwiftUI
- Customizable overlay content
- Touches pass through wherever the overlay draws nothing
- Inherits the environment of the view it's attached to
- Keeps the app's status bar style and color scheme

## Usage
To use WindowOverlay in your SwiftUI view, simply apply the `windowOverlay` modifier:
```swift
struct ContentView: View {
  @State private var showOverlay = false

  var body: some View {
    VStack {
      Button("Show Overlay") {
        showOverlay.toggle()
      }
    }
    .windowOverlay(isPresented: showOverlay) {
      Text("This is an overlay")
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(10)
    }
  }
}
```

### Touches
The overlay takes touches wherever it draws something, including materials and UIKit-backed controls like `TextField` and `Toggle`. Everything else, including views with `.allowsHitTesting(false)`, passes through to your app.

A clear `contentShape` draws nothing, so touches there pass through too. For an invisible tap area, draw a nearly transparent color instead:

```swift
Color.black.opacity(0.001)
  .onTapGesture { ... }
```

## Requirements
- iOS 13.0+
- Swift 5.9+
