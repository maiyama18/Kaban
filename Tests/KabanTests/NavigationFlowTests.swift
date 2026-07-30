import SwiftUI
import Testing
import UIKit
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

@MainActor
private func makeNavigationFlowContainer(
    flow: NavigationFlow<PushDestination, SheetDestination, FullScreenDestination>
) -> NavigationFlowContainer<PushDestination, SheetDestination, FullScreenDestination, EmptyView> {
    NavigationFlowContainer(
        flow: flow,
        pushDestination: { _ in EmptyView() },
        sheet: { _ in EmptyView() },
        fullScreen: { _ in EmptyView() },
        root: { EmptyView() }
    )
}

@MainActor
private func waitUntil(
    timeout: Duration = .seconds(1),
    condition: () -> Bool
) async -> Bool {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)

    while !condition() {
        guard clock.now < deadline else { return false }
        try? await Task.sleep(for: .milliseconds(10))
    }

    return true
}

@Test
func alertTitleIsOptional() {
    let alert = PresentableAlert(message: "Error") {
        Button("OK") {}
    }

    #expect(alert.title == nil)
}

@Test
func alertAcceptsTitle() {
    let alert = PresentableAlert(title: "Warning", message: "Error") {
        Button("OK") {}
    }

    #expect(alert.title == "Warning")
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
func sheetFlowDismissesItselfFromParent() {
    let flow = NavigationFlow<PushDestination, SheetDestination, FullScreenDestination>()

    flow.presentSheet(.settings)
    let sheetFlow = flow.visibleNavigationFlow
    sheetFlow.dismiss()

    #expect(flow.presentedSheet == nil)
    #expect(flow.visibleNavigationFlow === flow)
}

@Test
@MainActor
func fullScreenFlowDismissesItselfFromParent() {
    let flow = NavigationFlow<PushDestination, SheetDestination, FullScreenDestination>()

    flow.presentFullScreen(.onboarding)
    let fullScreenFlow = flow.visibleNavigationFlow
    fullScreenFlow.dismiss()

    #expect(flow.presentedFullScreen == nil)
    #expect(flow.visibleNavigationFlow === flow)
}

@Test
@MainActor
func rootFlowDismissDoesNothing() {
    let flow = NavigationFlow<PushDestination, SheetDestination, FullScreenDestination>()

    flow.dismiss()

    #expect(flow.visibleNavigationFlow === flow)
}

@Test
@MainActor
func childFlowDoesNotRetainParent() {
    var flow: NavigationFlow<PushDestination, SheetDestination, FullScreenDestination>? = NavigationFlow()
    weak let parentFlow = flow

    flow?.presentSheet(.settings)
    let childFlow = flow?.visibleNavigationFlow
    flow = nil

    #expect(parentFlow == nil)
    childFlow?.dismiss()
}

@Test
@MainActor
func replacedChildFlowDoesNotDismissCurrentPresentation() {
    let flow = NavigationFlow<PushDestination, SheetDestination, FullScreenDestination>()

    flow.presentSheet(.settings)
    let replacedSheetFlow = flow.visibleNavigationFlow
    flow.presentFullScreen(.onboarding)
    replacedSheetFlow.dismiss()

    #expect(flow.presentedSheet == nil)
    #expect(flow.presentedFullScreen == .onboarding)
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
func sheetBindingTracksPresentationUpdates() async {
    let flow = NavigationFlow<PushDestination, SheetDestination, FullScreenDestination>()
    let container = makeNavigationFlowContainer(flow: flow)

    await confirmation { stateChanged in
        let binding = withObservationTracking {
            container.presentedSheetBinding
        } onChange: {
            stateChanged()
        }

        flow.presentSheet(.settings)

        #expect(binding.wrappedValue?.sheet == .settings)

        binding.wrappedValue = nil

        #expect(flow.presentedSheet == nil)
    }
}

@Test
@MainActor
func fullScreenBindingTracksPresentationUpdates() async {
    let flow = NavigationFlow<PushDestination, SheetDestination, FullScreenDestination>()
    let container = makeNavigationFlowContainer(flow: flow)

    await confirmation { stateChanged in
        let binding = withObservationTracking {
            container.presentedFullScreenBinding
        } onChange: {
            stateChanged()
        }

        flow.presentFullScreen(.onboarding)

        #expect(binding.wrappedValue?.fullScreen == .onboarding)

        binding.wrappedValue = nil

        #expect(flow.presentedFullScreen == nil)
    }
}

@Test
@MainActor
func sheetPresentationAppearsAfterStateUpdate() async {
    let flow = NavigationFlow<PushDestination, SheetDestination, FullScreenDestination>()
    let hostingController = UIHostingController(rootView: makeNavigationFlowContainer(flow: flow))
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = hostingController
    window.makeKeyAndVisible()

    #expect(await waitUntil {
        hostingController.viewIfLoaded?.window != nil
    })

    flow.presentSheet(.settings)

    #expect(await waitUntil {
        hostingController.presentedViewController != nil
    })

    window.isHidden = true
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
