import SwiftUI

extension View {
  public func windowOverlay<V: View>(isPresented: Bool, @ViewBuilder content: () -> V) -> some View {
    modifier(WindowOverlayModifier(isPresented: isPresented, overlay: content()))
  }
}

private struct WindowOverlayModifier<V: View>: ViewModifier {
  var isPresented: Bool
  var overlay: V

  func body(content: Content) -> some View {
    content
      ._background {
        WindowBridgingView(isPresented: isPresented, content: overlay)
          .allowsHitTesting(false)
      }
  }
}
