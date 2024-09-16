# WindowOverlay
WindowOverlay is a Swift package that provides a convenient way to add overlay views to your SwiftUI application's window. This package is designed to work seamlessly with SwiftUI, offering a flexible solution for displaying content above your main app interface.

## Features
- Easy integration with SwiftUI
- Customizable overlay content
- Transparent hit-testing for non-interactive overlays

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
      .background(Color.white)
      .cornerRadius(10)
    }
  }
}
```

## How it works
WindowOverlay uses a combination of SwiftUI and UIKit to create a seamless overlay experience:
1. The `windowOverlay` modifier is applied to your SwiftUI view.
1. A `WindowBridgingView` is created to bridge between SwiftUI and UIKit.
1. A custom `WindowOverlayWindow` is created and added to the app's window hierarchy.
1. The overlay content is rendered in the custom window, appearing above the main app content.

## Requirements
- iOS 13.0+
- Swift 5.9+
