import SwiftUI

public struct PresentableAlert: Sendable {
    internal let title: String?
    internal let message: String
    internal let actions: @Sendable @MainActor () -> AnyView

    public init(title: String? = nil, message: String, @ViewBuilder actions: @escaping @Sendable @MainActor () -> some View) {
        let builder = actions
        self.title = title
        self.message = message
        self.actions = { AnyView(builder()) }
    }
}
