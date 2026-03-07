import SwiftUI

public struct PresentableAlert: Sendable {
    internal let message: String
    internal let actions: @Sendable @MainActor () -> AnyView

    public init(message: String, @ViewBuilder actions: @escaping @Sendable @MainActor () -> some View) {
        let builder = actions
        self.message = message
        self.actions = { AnyView(builder()) }
    }
}
