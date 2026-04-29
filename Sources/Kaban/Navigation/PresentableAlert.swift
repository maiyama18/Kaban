import SwiftUI

/// Alert content that can be presented by ``NavigationFlow``.
public struct PresentableAlert: Sendable {
    internal let title: String?
    internal let message: String
    internal let actions: @Sendable @MainActor () -> AnyView

    /// Creates alert content.
    ///
    /// - Parameters:
    ///   - title: Optional alert title. Pass `nil` for a message-only alert.
    ///   - message: Alert message text.
    ///   - actions: Alert actions, such as `Button` values.
    public init(title: String? = nil, message: String, @ViewBuilder actions: @escaping @Sendable @MainActor () -> some View) {
        let builder = actions
        self.title = title
        self.message = message
        self.actions = { AnyView(builder()) }
    }
}
