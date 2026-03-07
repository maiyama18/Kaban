import SwiftUI
import UIKit

extension NSNotification.Name {
    internal static let deviceDidShake: NSNotification.Name = .init("DeviceDidShake")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            NotificationCenter.default.post(name: .deviceDidShake, object: nil)
        }
    }
}

private struct OnShakeModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: .deviceDidShake)) { _ in
                action()
            }
    }
}

extension View {
    public func onShake(perform action: @escaping () -> Void) -> some View {
        modifier(OnShakeModifier(action: action))
    }
}
