import SwiftUI
import UIKit

internal struct WindowBridgingView<V: View>: UIViewRepresentable {
  var isPresented: Bool
  var content: V

  func makeUIView(context: Context) -> _HelperView {
    let hostingController = UIHostingController(rootView: EnvPassingView(
      content: content,
      environment: context.environment
    ))
    hostingController.view.backgroundColor = .clear
    return _HelperView(hostingController: hostingController)
  }
  func updateUIView(_ helper: _HelperView, context: Context) {
    helper.hostingController.rootView = EnvPassingView(
      content: content,
      environment: context.environment
    )
    helper.isPresented = isPresented
  }

  fileprivate struct EnvPassingView: View {
    var content: V
    var environment: EnvironmentValues

    var body: some View {
      content.environment(\.self, environment)
    }
  }

  internal final class _HelperView: UIView {
    var isPresented = false {
      didSet { overlayWindow?.isHidden = !isPresented }
    }
    private var overlayWindow: WindowOverlayWindow?
    fileprivate let hostingController: UIHostingController<EnvPassingView>

    fileprivate init(hostingController: UIHostingController<EnvPassingView>) {
      self.hostingController = hostingController
      super.init(frame: .zero)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func willMove(toWindow newWindow: UIWindow?) {
      super.willMove(toWindow: newWindow)
      if let windowScene = newWindow?.windowScene {
        overlayWindow = WindowOverlayWindow(
          windowScene: windowScene,
          rootViewController: hostingController
        )
        overlayWindow?.isHidden = !isPresented
      }
    }
  }
}
