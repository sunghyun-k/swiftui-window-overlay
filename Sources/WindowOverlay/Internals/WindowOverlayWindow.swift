import UIKit

internal final class WindowOverlayWindow: UIWindow {
  init(windowScene: UIWindowScene, rootViewController: UIViewController) {
    super.init(windowScene: windowScene)
    self.windowLevel = .alert
    self.rootViewController = rootViewController
  }
  required init?(coder: NSCoder) { fatalError() }

  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard let rootViewController = self.rootViewController,
          let view = super.hitTest(point, with: event)
    else { return nil }

    if view == rootViewController.view {
      let color = self.colorOfPoint(point)
      if color.alpha < 0.01 {
        return nil
      }
    }
    return view
  }
}
