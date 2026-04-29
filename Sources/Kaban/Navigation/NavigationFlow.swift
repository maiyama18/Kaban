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

/// Navigation and presentation state for a ``NavigationFlowContainer``.
///
/// A flow owns one navigation stack path and at most one active presentation:
/// sheet, full-screen cover, or alert. Presented sheets and full-screen covers
/// receive their own nested flow.
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

    /// Destinations currently pushed in the navigation stack.
    public var path: [PushableDestination] = []
    internal var presentedContent: PresentedContent?
    /// The deepest visible flow, following presented sheets and full-screen covers.
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

    /// Creates an empty navigation flow.
    public init() {}

    /// Pushes a destination onto the navigation stack.
    public func push(_ destination: PushableDestination) {
        path.append(destination)
    }

    /// Pops the last destination from the navigation stack if one exists.
    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Removes all pushed destinations.
    public func popAll() {
        path.removeAll()
    }

    /// Presents a sheet and gives that sheet its own nested navigation flow.
    public func presentSheet(_ sheet: PresentableSheet) {
        presentedContent = .sheet(
            PresentedSheetContent(
                navigationFlow: NavigationFlow(),
                sheet: sheet
            )
        )
    }

    /// Presents a full-screen cover and gives that cover its own nested navigation flow.
    public func presentFullScreen(_ fullScreen: PresentableFullScreen) {
        presentedContent = .fullScreen(
            PresentedFullScreenContent(
                navigationFlow: NavigationFlow(),
                fullScreen: fullScreen
            )
        )
    }

    /// Presents an alert.
    public func presentAlert(_ alert: PresentableAlert) {
        presentedContent = .alert(alert)
    }

    /// Dismisses the active sheet, full-screen cover, or alert.
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
