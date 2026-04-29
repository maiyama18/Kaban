import SwiftUI

internal struct NavigationFlowPresentedSheetContent<
    PushableDestination: Hashable & Sendable,
    PresentableSheet: Identifiable & Sendable,
    PresentableFullScreen: Identifiable & Sendable
>: Identifiable, Sendable {
    internal let navigationFlow: NavigationFlow<PushableDestination, PresentableSheet, PresentableFullScreen>
    internal let sheet: PresentableSheet

    internal var id: PresentableSheet.ID { sheet.id }
}

internal struct NavigationFlowPresentedFullScreenContent<
    PushableDestination: Hashable & Sendable,
    PresentableSheet: Identifiable & Sendable,
    PresentableFullScreen: Identifiable & Sendable
>: Identifiable, Sendable {
    internal let navigationFlow: NavigationFlow<PushableDestination, PresentableSheet, PresentableFullScreen>
    internal let fullScreen: PresentableFullScreen

    internal var id: PresentableFullScreen.ID { fullScreen.id }
}

internal enum NavigationFlowPresentedContent<
    PushableDestination: Hashable & Sendable,
    PresentableSheet: Identifiable & Sendable,
    PresentableFullScreen: Identifiable & Sendable
>: Sendable {
    case sheet(NavigationFlowPresentedSheetContent<PushableDestination, PresentableSheet, PresentableFullScreen>)
    case fullScreen(NavigationFlowPresentedFullScreenContent<PushableDestination, PresentableSheet, PresentableFullScreen>)
    case alert(PresentableAlert)
}

@Observable
@MainActor
public final class NavigationFlow<
    PushableDestination: Hashable & Sendable,
    PresentableSheet: Identifiable & Sendable,
    PresentableFullScreen: Identifiable & Sendable
>: Sendable {
    internal typealias PresentedContent = NavigationFlowPresentedContent<PushableDestination, PresentableSheet, PresentableFullScreen>
    internal typealias PresentedSheetContent = NavigationFlowPresentedSheetContent<PushableDestination, PresentableSheet, PresentableFullScreen>
    internal typealias PresentedFullScreenContent = NavigationFlowPresentedFullScreenContent<PushableDestination, PresentableSheet, PresentableFullScreen>

    public var path: [PushableDestination] = []
    internal var presentedContent: PresentedContent?
    public var visibleNavigationFlow: NavigationFlow {
        switch presentedContent {
        case .sheet(let content):
            content.navigationFlow.visibleNavigationFlow
        case .fullScreen(let content):
            content.navigationFlow.visibleNavigationFlow
        case .alert, nil:
            self
        }
    }
    internal var presentedSheetContent: PresentedSheetContent? {
        guard case let .sheet(content) = presentedContent else { return nil }
        return content
    }
    internal var presentedSheet: PresentableSheet? {
        presentedSheetContent?.sheet
    }
    internal var presentedFullScreenContent: PresentedFullScreenContent? {
        guard case let .fullScreen(content) = presentedContent else { return nil }
        return content
    }
    internal var presentedFullScreen: PresentableFullScreen? {
        presentedFullScreenContent?.fullScreen
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
        presentedContent = .sheet(
            PresentedSheetContent(
                navigationFlow: NavigationFlow(),
                sheet: sheet
            )
        )
    }

    public func presentFullScreen(_ fullScreen: PresentableFullScreen) {
        presentedContent = .fullScreen(
            PresentedFullScreenContent(
                navigationFlow: NavigationFlow(),
                fullScreen: fullScreen
            )
        )
    }

    public func presentAlert(_ alert: PresentableAlert) {
        presentedContent = .alert(alert)
    }

    public func dismissPresentedContent() {
        presentedContent = nil
    }

    internal func dismissSheet() {
        guard case .sheet = presentedContent else { return }
        presentedContent = nil
    }

    internal func dismissFullScreen() {
        guard case .fullScreen = presentedContent else { return }
        presentedContent = nil
    }

    internal func dismissAlert() {
        guard case .alert = presentedContent else { return }
        presentedContent = nil
    }
}
