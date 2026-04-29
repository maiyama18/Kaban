import SwiftUI

internal enum NavigationFlowPresentedContent<
    PresentableSheet: Identifiable & Sendable,
    PresentableFullScreen: Identifiable & Sendable
>: Sendable {
    case sheet(PresentableSheet)
    case fullScreen(PresentableFullScreen)
    case alert(PresentableAlert)
}

@Observable
@MainActor
public final class NavigationFlow<
    PushableDestination: Hashable & Sendable,
    PresentableSheet: Identifiable & Sendable,
    PresentableFullScreen: Identifiable & Sendable
>: Sendable {
    internal typealias PresentedContent = NavigationFlowPresentedContent<PresentableSheet, PresentableFullScreen>

    public var path: [PushableDestination] = []
    internal var presentedContent: PresentedContent?
    internal var presentedSheet: PresentableSheet? {
        guard case let .sheet(sheet) = presentedContent else { return nil }
        return sheet
    }
    internal var presentedFullScreen: PresentableFullScreen? {
        guard case let .fullScreen(fullScreen) = presentedContent else { return nil }
        return fullScreen
    }
    internal var presentedAlert: PresentableAlert? {
        guard case let .alert(alert) = presentedContent else { return nil }
        return alert
    }

    public init() {}

    public func push(_ destination: PushableDestination) {
        path.append(destination)
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popAll() {
        path.removeAll()
    }

    public func presentSheet(_ sheet: PresentableSheet) {
        presentedContent = .sheet(sheet)
    }

    public func presentFullScreen(_ fullScreen: PresentableFullScreen) {
        presentedContent = .fullScreen(fullScreen)
    }

    public func presentAlert(_ alert: PresentableAlert) {
        presentedContent = .alert(alert)
    }

    public func dismissPresentedContent() {
        presentedContent = nil
    }
}
