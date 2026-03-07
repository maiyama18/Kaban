import SwiftUI

private struct OnFirstAppearModifier: ViewModifier {
    @State private var appeared = false
    let action: @MainActor () async -> Void

    func body(content: Content) -> some View {
        content
            .task {
                guard !appeared else { return }
                appeared = true
                await action()
            }
    }
}

extension View {
    public func onFirstAppear(_ action: @escaping @MainActor () async -> Void) -> some View {
        modifier(OnFirstAppearModifier(action: action))
    }
}
