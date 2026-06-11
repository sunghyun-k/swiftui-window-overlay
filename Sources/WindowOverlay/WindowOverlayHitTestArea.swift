import SwiftUI
import UIKit

public struct WindowOverlayHitTestArea: UIViewRepresentable {
  public init() {}

  public func makeUIView(context: Context) -> UIView {
    WindowOverlayHitTestAreaView()
  }

  public func updateUIView(_ uiView: UIView, context: Context) {}
}

internal final class WindowOverlayHitTestAreaView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear
    isUserInteractionEnabled = false
  }

  required init?(coder: NSCoder) { fatalError() }
}
