import SwiftUI

@Observable
@MainActor
public final class NavigationFlow<
    PushableDestination: Hashable & Sendable,
    PresentableSheet: Identifiable & Sendable,
    PresentableFullScreen: Identifiable & Sendable
>: Sendable {
    public var path: [PushableDestination] = []
    public var presentedSheet: PresentableSheet?
    public var presentedFullScreen: PresentableFullScreen?
    public var presentedAlert: PresentableAlert?

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
        presentedSheet = sheet
    }

    public func presentFullScreen(_ fullScreen: PresentableFullScreen) {
        presentedFullScreen = fullScreen
    }

    public func presentAlert(_ alert: PresentableAlert) {
        presentedAlert = alert
    }

    public func dismissPresentedContent() {
        presentedSheet = nil
        presentedFullScreen = nil
        presentedAlert = nil
    }
}
