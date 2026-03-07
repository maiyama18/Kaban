import SwiftUI

public struct PresentableAlert: Sendable {
    public let message: String
    public let actions: @Sendable @MainActor () -> AnyView

    public init(message: String, @ViewBuilder actions: @escaping @Sendable @MainActor () -> some View) {
        let builder = actions
        self.message = message
        self.actions = { AnyView(builder()) }
    }
}
