import SwiftUI

extension View {
  @ViewBuilder
  nonisolated internal func _background(
    alignment: Alignment = .center,
    @ViewBuilder content: () -> some View
  ) -> some View {
    if #available(iOS 15.0, *) {
      self.background(alignment: alignment, content: content)
    } else {
      self.background(content(), alignment: alignment)
    }
  }
}
