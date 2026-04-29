import SwiftUI
import Testing
@testable import Kaban

private enum PushDestination: Hashable, Sendable {
    case detail
}

private enum SheetDestination: String, Identifiable, Sendable {
    case settings

    fileprivate var id: String { rawValue }
}

private enum FullScreenDestination: String, Identifiable, Sendable {
    case onboarding

    fileprivate var id: String { rawValue }
}

@Test
@MainActor
func presentationStateIsMutuallyExclusive() {
    let flow = NavigationFlow<PushDestination, SheetDestination, FullScreenDestination>()

    flow.presentSheet(.settings)

    #expect(flow.presentedSheet == .settings)
    #expect(flow.presentedFullScreen == nil)
    #expect(flow.presentedAlert == nil)

    flow.presentFullScreen(.onboarding)

    #expect(flow.presentedSheet == nil)
    #expect(flow.presentedFullScreen == .onboarding)
    #expect(flow.presentedAlert == nil)

    flow.presentAlert(PresentableAlert(message: "Error") {
        Button("OK") {}
    })

    #expect(flow.presentedSheet == nil)
    #expect(flow.presentedFullScreen == nil)
    #expect(flow.presentedAlert != nil)
}

@Test
@MainActor
func dismissPresentedContentClearsCurrentPresentation() {
    let flow = NavigationFlow<PushDestination, SheetDestination, FullScreenDestination>()

    flow.presentFullScreen(.onboarding)
    flow.dismissPresentedContent()

    #expect(flow.presentedSheet == nil)
    #expect(flow.presentedFullScreen == nil)
    #expect(flow.presentedAlert == nil)
}

@Test
@MainActor
func typedDismissDoesNotClearDifferentPresentation() {
    let flow = NavigationFlow<PushDestination, SheetDestination, FullScreenDestination>()

    flow.presentSheet(.settings)
    flow.presentFullScreen(.onboarding)
    flow.dismissSheet()

    #expect(flow.presentedSheet == nil)
    #expect(flow.presentedFullScreen == .onboarding)
    #expect(flow.presentedAlert == nil)

    flow.presentAlert(PresentableAlert(message: "Error") {
        Button("OK") {}
    })
    flow.dismissFullScreen()

    #expect(flow.presentedSheet == nil)
    #expect(flow.presentedFullScreen == nil)
    #expect(flow.presentedAlert != nil)
}

@Test
@MainActor
func visibleNavigationFlowReturnsTopmostPresentedFlow() {
    let flow = NavigationFlow<PushDestination, SheetDestination, FullScreenDestination>()

    #expect(flow.visibleNavigationFlow === flow)

    flow.presentSheet(.settings)

    let sheetFlow = flow.visibleNavigationFlow

    #expect(sheetFlow !== flow)
    #expect(sheetFlow.visibleNavigationFlow === sheetFlow)

    sheetFlow.presentFullScreen(.onboarding)

    let fullScreenFlow = sheetFlow.visibleNavigationFlow

    #expect(fullScreenFlow !== sheetFlow)
    #expect(flow.visibleNavigationFlow === fullScreenFlow)

    fullScreenFlow.presentAlert(PresentableAlert(message: "Error") {
        Button("OK") {}
    })

    #expect(flow.visibleNavigationFlow === fullScreenFlow)
}
