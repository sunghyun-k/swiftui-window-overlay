import UIKit

internal final class WindowOverlayWindow: UIWindow {
  override init(windowScene: UIWindowScene) {
    super.init(windowScene: windowScene)
    // Above sheets and the keyboard, below system alerts.
    self.windowLevel = .alert - 1
    self.backgroundColor = .clear
  }
  required init?(coder: NSCoder) { fatalError() }

  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard let rootView = rootViewController?.view,
          let hitView = super.hitTest(point, with: event)
    else { return nil }

    // UIKit-backed controls, and before iOS 26 everything SwiftUI draws, are subviews of the hosting view.
    if hitView !== rootView {
      return hitView
    }
    // From iOS 26, SwiftUI draws into layers under the hosting view's own layer.
    if #available(iOS 26.0, *),
       let layer = rootView.layer.hitTest(point),
       layer !== rootView.layer
    {
      return hitView
    }
    return nil
  }
}
