import UIKit

internal final class WindowOverlayWindow: UIWindow {
  override init(windowScene: UIWindowScene) {
    super.init(windowScene: windowScene)
    self.windowLevel = .alert
  }
  required init?(coder: NSCoder) { fatalError() }

  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard let rootViewController,
          let hitView = super.hitTest(point, with: event)
    else { return nil }

    let rootView = rootViewController.view!
    if rootView.hasWindowOverlayHitTestAreas {
      return rootView.containsWindowOverlayHitTestArea(at: point, from: self) ? hitView : nil
    }

    if hitView == rootView {
      let color = self.colorOfPoint(point)
      if color.alpha < 0.01 {
        return nil
      }
    }

    return hitView
  }
}

private extension UIView {
  var hasWindowOverlayHitTestAreas: Bool {
    if self is WindowOverlayHitTestAreaView { return true }
    return subviews.contains { $0.hasWindowOverlayHitTestAreas }
  }

  func containsWindowOverlayHitTestArea(at point: CGPoint, from coordinateSpace: UIView) -> Bool {
    if let marker = self as? WindowOverlayHitTestAreaView {
      let localPoint = marker.convert(point, from: coordinateSpace)
      return !marker.isHidden && marker.alpha > 0.01 && marker.point(inside: localPoint, with: nil)
    }

    return subviews.contains {
      $0.containsWindowOverlayHitTestArea(at: point, from: coordinateSpace)
    }
  }
}
