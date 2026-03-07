import SwiftUI

private struct OnBackgroundModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    let action: @Sendable () async -> Void

    func body(content: Content) -> some View {
        content
            .task(id: scenePhase) {
                guard scenePhase == .background else { return }
                await action()
            }
    }
}

extension View {
    public func onBackground(_ action: @escaping @Sendable () async -> Void) -> some View {
        modifier(OnBackgroundModifier(action: action))
    }
}
