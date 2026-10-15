import SwiftUI
import UIKit
import WindowOverlay

/// Shows an overlay with every hit test case.
///
/// Run it normally to tap around by hand: taps on the overlay show at the top, taps that reach the app
/// show at the bottom. Launch it with `-check` to call the overlay window's hit test at each case,
/// print the results, and exit (see `check.sh`).
@main
struct HitTestCheckApp: App {
  var body: some Scene {
    WindowGroup { RootView() }
  }
}

private let isCheck = ProcessInfo.processInfo.arguments.contains("-check")

private struct RootView: View {
  @State private var isPresented = isCheck
  @State private var appTaps = 0
  @State private var lastOverlayTap = "-"
  @State private var frames: [String: CGRect] = [:]

  var body: some View {
    Button {
      appTaps += 1
    } label: {
      VStack {
        Spacer()
        Text("Taps reached the app: \(appTaps)")
        Toggle("Overlay", isOn: $isPresented).fixedSize()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .padding(.bottom, 40)
      .background(Color(.systemGroupedBackground))
    }
    .buttonStyle(.plain)
    .ignoresSafeArea()
    .windowOverlay(isPresented: isPresented) {
      OverlayView(lastTap: $lastOverlayTap)
        .onPreferenceChange(CaseFramesKey.self) { frames = $0 }
    }
    .task {
      guard isCheck else { return }
      try? await Task.sleep(nanoseconds: 1_500_000_000)
      runCheck(frames: frames)
      isPresented = false
      try? await Task.sleep(nanoseconds: 500_000_000)
      checkTeardown()
      exit(0)
    }
  }
}

// MARK: - Cases

private struct HitTestCase {
  var name: String
  var takesTouch: Bool
  var view: AnyView
}

private func cases(tap: @escaping (String) -> Void) -> [HitTestCase] {
  var cases = [
    HitTestCase(name: "Button", takesTouch: true, view: AnyView(
      Button("Button") { tap("Button") }
    )),
    HitTestCase(name: "Material", takesTouch: true, view: AnyView(
      Text("Material").padding(8).background(.ultraThinMaterial).onTapGesture { tap("Material") }
    )),
    HitTestCase(name: "Opaque color", takesTouch: true, view: AnyView(
      Color.red.frame(width: 60, height: 32)
    )),
    HitTestCase(name: "Toggle", takesTouch: true, view: AnyView(
      Toggle("", isOn: .constant(true)).labelsHidden()
    )),
    HitTestCase(name: "ScrollView", takesTouch: true, view: AnyView(
      ScrollView { Text(String(repeating: "Scroll\n", count: 10)) }.frame(width: 80, height: 32)
    )),
    HitTestCase(name: "TextField", takesTouch: true, view: AnyView(
      TextField("TextField", text: .constant("")).frame(width: 100)
    )),
    HitTestCase(name: "opacity(0.001)", takesTouch: true, view: AnyView(
      Color.black.opacity(0.001).frame(width: 60, height: 32).onTapGesture { tap("opacity(0.001)") }
    )),
    HitTestCase(name: "allowsHitTesting(false)", takesTouch: false, view: AnyView(
      Color.blue.frame(width: 60, height: 32).allowsHitTesting(false)
    )),
    HitTestCase(name: "Empty space", takesTouch: false, view: AnyView(
      Color.clear.frame(width: 60, height: 32)
    )),
    // Known limitation: a clear content shape draws nothing.
    HitTestCase(name: "Clear contentShape", takesTouch: false, view: AnyView(
      Color.clear.frame(width: 60, height: 32).contentShape(Rectangle())
        .onTapGesture { tap("Clear contentShape") }
    )),
  ]
  if #available(iOS 26.0, *) {
    cases += [
      HitTestCase(name: "glassEffect", takesTouch: true, view: AnyView(
        Text("Glass").padding(8).glassEffect().onTapGesture { tap("glassEffect") }
      )),
      HitTestCase(name: "Glass button", takesTouch: true, view: AnyView(
        Button("Glass") { tap("Glass button") }.buttonStyle(.glass)
      )),
    ]
  }
  return cases
}

private struct OverlayView: View {
  @Binding var lastTap: String

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Last overlay tap: \(lastTap)")
        .padding(8)
        .background(Color(.systemBackground))
      ForEach(cases { lastTap = $0 }, id: \.name) { item in
        HStack {
          Text(item.name)
            .font(.caption)
            .frame(width: 160, alignment: .leading)
          item.view
            .background {
              GeometryReader { geometry in
                Color.clear.preference(
                  key: CaseFramesKey.self, value: [item.name: geometry.frame(in: .global)]
                )
              }
            }
        }
      }
    }
    .padding(.leading, 20)
    .padding(.top, 80)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}

private struct CaseFramesKey: PreferenceKey {
  static let defaultValue: [String: CGRect] = [:]

  static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
    value.merge(nextValue()) { $1 }
  }
}

// MARK: - Check

private func overlayWindow() -> UIWindow? {
  UIApplication.shared.connectedScenes
    .compactMap { $0 as? UIWindowScene }
    .flatMap(\.windows)
    .first { String(describing: type(of: $0)) == "WindowOverlayWindow" }
}

private func runCheck(frames: [String: CGRect]) {
  print("CHECK iOS \(UIDevice.current.systemVersion)")
  guard let window = overlayWindow() else {
    print("CHECK FAIL: no overlay window")
    return
  }
  for item in cases(tap: { _ in }) {
    guard let frame = frames[item.name] else {
      print("CHECK FAIL \(item.name): no frame")
      continue
    }
    let point = CGPoint(x: frame.midX, y: frame.midY)
    let takesTouch = window.hitTest(point, with: nil) != nil
    let result = takesTouch == item.takesTouch ? "ok  " : "FAIL"
    print("CHECK \(result) \(item.name): \(takesTouch ? "takes the touch" : "passes through")")
  }
}

private func checkTeardown() {
  let window = overlayWindow()
  let isTornDown = window == nil || (window!.isHidden && window!.rootViewController == nil)
  print("CHECK \(isTornDown ? "ok  " : "FAIL") Dismiss: \(isTornDown ? "torn down" : "still visible")")
}
