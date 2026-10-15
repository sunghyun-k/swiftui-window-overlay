import SwiftUI
import UIKit

internal struct WindowBridgingView<V: View>: UIViewRepresentable {
  var isPresented: Bool
  var disableSafeArea: Bool
  var content: V

  func makeUIView(context: Context) -> _HelperView {
    _HelperView()
  }

  func updateUIView(_ helper: _HelperView, context: Context) {
    helper.update(
      isPresented: isPresented,
      disableSafeArea: disableSafeArea,
      content: content,
      environment: context.environment
    )
  }

  /// The overlay window is outside the SwiftUI hierarchy, so the environment is passed explicitly.
  fileprivate struct RootView: View {
    var content: V
    var environment: EnvironmentValues

    var body: some View {
      content.environment(\.self, environment)
    }
  }

  internal final class _HelperView: UIView {
    private var isPresented = false
    private var disableSafeArea = false
    private var content: V?
    private var environment = EnvironmentValues()

    private var overlayWindow: WindowOverlayWindow?
    private var hostingController: StatusBarForwardingHostingController<RootView>?

    override func didMoveToWindow() {
      super.didMoveToWindow()
      if let windowScene = window?.windowScene {
        if overlayWindow?.windowScene !== windowScene {
          tearDown()
          overlayWindow = WindowOverlayWindow(windowScene: windowScene)
        }
        updateWindow()
      } else {
        tearDown()
      }
    }

    fileprivate func update(
      isPresented: Bool,
      disableSafeArea: Bool,
      content: V,
      environment: EnvironmentValues
    ) {
      self.isPresented = isPresented
      self.disableSafeArea = disableSafeArea
      self.content = content
      self.environment = environment
      updateWindow()
    }

    private func updateWindow() {
      guard let overlayWindow, let content else { return }
      guard isPresented else {
        overlayWindow.isHidden = true
        overlayWindow.rootViewController = nil
        hostingController = nil
        return
      }
      let rootView = RootView(content: content, environment: environment)
      if let hostingController {
        hostingController.rootView = rootView
      } else {
        let controller = StatusBarForwardingHostingController(rootView: rootView)
        controller.view.backgroundColor = .clear
        overlayWindow.rootViewController = controller
        hostingController = controller
      }
      hostingController?.disableSafeArea(disableSafeArea)
      hostingController?.sourceWindow = window
      // Match the app window so the status bar text keeps its color (`.preferredColorScheme` applies there).
      overlayWindow.overrideUserInterfaceStyle = window?.overrideUserInterfaceStyle ?? .unspecified
      overlayWindow.isHidden = false
      hostingController?.setNeedsStatusBarAppearanceUpdate()
    }

    private func tearDown() {
      overlayWindow?.isHidden = true
      overlayWindow?.rootViewController = nil
      overlayWindow = nil
      hostingController = nil
    }
  }
}

extension UIHostingController {
  func disableSafeArea(_ disable: Bool) {
    if #available(iOS 16.4, *) {
      self.safeAreaRegions = disable ? [] : .all
    } else {
      self._disableSafeArea = disable
    }
  }
}
