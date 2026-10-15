import SwiftUI
import UIKit

/// The topmost window's root controller decides the status bar. Forwards the app window's values
/// so the overlay doesn't take over the status bar.
internal final class StatusBarForwardingHostingController<Content: View>: UIHostingController<Content> {
  weak var sourceWindow: UIWindow?

  override var prefersStatusBarHidden: Bool {
    source { $0.childForStatusBarHidden }?.prefersStatusBarHidden
      ?? super.prefersStatusBarHidden
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    source { $0.childForStatusBarStyle }?.preferredStatusBarStyle
      ?? super.preferredStatusBarStyle
  }

  override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    source { $0.childForStatusBarHidden }?.preferredStatusBarUpdateAnimation
      ?? super.preferredStatusBarUpdateAnimation
  }

  /// Same rule as UIKit: walk up to the controller presented full screen or capturing the status bar,
  /// then follow its children.
  private func source(child: (UIViewController) -> UIViewController?) -> UIViewController? {
    guard var controller = sourceWindow?.rootViewController else { return nil }
    while let presented = controller.presentedViewController,
          !presented.isBeingDismissed,
          presented.modalPresentationStyle == .fullScreen
            || presented.modalPresentationCapturesStatusBarAppearance
    {
      controller = presented
    }
    while let next = child(controller), next !== controller {
      controller = next
    }
    return controller
  }
}
