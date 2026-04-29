import SwiftUI

public struct NavigationFlowContainer<
    PushableDestination: Hashable & Sendable,
    PresentableSheet: Identifiable & Sendable,
    PresentableFullScreen: Identifiable & Sendable,
    Root: View
>: View {
    @Bindable private var flow: NavigationFlow<PushableDestination, PresentableSheet, PresentableFullScreen>
    private let pushDestinationBuilder: (PushableDestination) -> AnyView
    private let sheetBuilder: (PresentableSheet) -> AnyView
    private let fullScreenBuilder: (PresentableFullScreen) -> AnyView
    private let root: Root

    public init(
        flow: NavigationFlow<PushableDestination, PresentableSheet, PresentableFullScreen>,
        @ViewBuilder pushDestination: @escaping (PushableDestination) -> some View,
        @ViewBuilder sheet: @escaping (PresentableSheet) -> some View,
        @ViewBuilder fullScreen: @escaping (PresentableFullScreen) -> some View,
        @ViewBuilder root: () -> Root
    ) {
        self.flow = flow
        self.pushDestinationBuilder = { AnyView(pushDestination($0)) }
        self.sheetBuilder = { AnyView(sheet($0)) }
        self.fullScreenBuilder = { AnyView(fullScreen($0)) }
        self.root = root()
    }

    public var body: some View {
        NavigationStack(path: $flow.path) {
            root
                .navigationDestination(for: PushableDestination.self) { destination in
                    pushDestinationBuilder(destination)
                }
        }
        .sheet(
            item: Binding(
                get: { flow.presentedSheetContent },
                set: { if $0 == nil { flow.dismissSheet() } }
            )
        ) { content in
            NavigationFlowContainer<PushableDestination, PresentableSheet, PresentableFullScreen, AnyView>(
                flow: content.navigationFlow,
                pushDestination: { destination in
                    pushDestinationBuilder(destination)
                },
                sheet: { sheet in
                    sheetBuilder(sheet)
                },
                fullScreen: { fullScreen in
                    fullScreenBuilder(fullScreen)
                },
                root: {
                    sheetBuilder(content.sheet)
                }
            )
        }
        .fullScreenCover(
            item: Binding(
                get: { flow.presentedFullScreenContent },
                set: { if $0 == nil { flow.dismissFullScreen() } }
            )
        ) { content in
            NavigationFlowContainer<PushableDestination, PresentableSheet, PresentableFullScreen, AnyView>(
                flow: content.navigationFlow,
                pushDestination: { destination in
                    pushDestinationBuilder(destination)
                },
                sheet: { sheet in
                    sheetBuilder(sheet)
                },
                fullScreen: { fullScreen in
                    fullScreenBuilder(fullScreen)
                },
                root: {
                    fullScreenBuilder(content.fullScreen)
                }
            )
        }
        .alert(
            flow.presentedAlert?.title ?? "",
            isPresented: Binding(
                get: { flow.presentedAlert != nil },
                set: { if !$0 { flow.dismissAlert() } }
            ),
            actions: {
                if let alert = flow.presentedAlert {
                    alert.actions()
                }
            },
            message: {
                if let alert = flow.presentedAlert {
                    Text(alert.message)
                }
            }
        )
        .environment(flow)
    }
}

extension NavigationFlowContainer where PresentableSheet == Never {
    public init(
        flow: NavigationFlow<PushableDestination, Never, PresentableFullScreen>,
        @ViewBuilder pushDestination: @escaping (PushableDestination) -> some View,
        @ViewBuilder fullScreen: @escaping (PresentableFullScreen) -> some View,
        @ViewBuilder root: () -> Root
    ) {
        self.flow = flow
        self.pushDestinationBuilder = { AnyView(pushDestination($0)) }
        self.sheetBuilder = { _ in fatalError() }
        self.fullScreenBuilder = { AnyView(fullScreen($0)) }
        self.root = root()
    }
}

extension NavigationFlowContainer where PresentableFullScreen == Never {
    public init(
        flow: NavigationFlow<PushableDestination, PresentableSheet, Never>,
        @ViewBuilder pushDestination: @escaping (PushableDestination) -> some View,
        @ViewBuilder sheet: @escaping (PresentableSheet) -> some View,
        @ViewBuilder root: () -> Root
    ) {
        self.flow = flow
        self.pushDestinationBuilder = { AnyView(pushDestination($0)) }
        self.sheetBuilder = { AnyView(sheet($0)) }
        self.fullScreenBuilder = { _ in fatalError() }
        self.root = root()
    }
}

extension NavigationFlowContainer where PresentableSheet == Never, PresentableFullScreen == Never {
    public init(
        flow: NavigationFlow<PushableDestination, Never, Never>,
        @ViewBuilder pushDestination: @escaping (PushableDestination) -> some View,
        @ViewBuilder root: () -> Root
    ) {
        self.flow = flow
        self.pushDestinationBuilder = { AnyView(pushDestination($0)) }
        self.sheetBuilder = { _ in fatalError() }
        self.fullScreenBuilder = { _ in fatalError() }
        self.root = root()
    }
}
