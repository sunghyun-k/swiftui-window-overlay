import SwiftUI

extension View {
  /// Presents `content` in a separate window above the app's window, including sheets and the keyboard.
  ///
  /// Touches pass through to the app wherever the overlay draws nothing.
  public func windowOverlay<V: View>(
    isPresented: Bool,
    disableSafeArea: Bool = false,
    @ViewBuilder content: () -> V
  ) -> some View {
    self._background {
      WindowBridgingView(
        isPresented: isPresented, disableSafeArea: disableSafeArea, content: content()
      )
      .allowsHitTesting(false)
    }
  }
}
