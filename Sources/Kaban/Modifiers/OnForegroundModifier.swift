import SwiftUI

private struct OnForegroundModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    let action: @Sendable () async -> Void

    func body(content: Content) -> some View {
        content
            .task(id: scenePhase) {
                guard scenePhase == .active else { return }
                await action()
            }
    }
}

extension View {
    public func onForeground(_ action: @escaping @Sendable () async -> Void) -> some View {
        modifier(OnForegroundModifier(action: action))
    }
}
