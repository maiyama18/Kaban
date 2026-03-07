import SwiftUI

public struct LoadingStateView<T: Sendable, LoadedContent: View>: View {
    private let state: LoadingState<T>
    private let loadedContent: (T) -> LoadedContent
    private let retryAction: (() async -> Void)?

    public init(
        state: LoadingState<T>,
        @ViewBuilder loadedContent: @escaping (T) -> LoadedContent,
        retryAction: (() async -> Void)? = nil
    ) {
        self.state = state
        self.loadedContent = loadedContent
        self.retryAction = retryAction
    }

    public var body: some View {
        switch state {
        case .empty, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let value):
            loadedContent(value)
        case .failed(let error):
            VStack(spacing: 24) {
                Text(error.localizedDescription)
                    .kabanTextStyle(.bodyRegular(), color: .textSecondary)
                    .multilineTextAlignment(.center)

                if let retryAction {
                    AsyncButton(action: retryAction) {
                        Text(.retry)
                    }
                    .buttonStyle(.kabanPrimary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview("Loaded") {
    LoadingStateView(state: .loaded("Hello World")) { value in
        Text(value)
    }
}

#Preview("Loading") {
    LoadingStateView(state: LoadingState<String>.loading) { value in
        Text(value)
    }
}

#Preview("Failed") {
    LoadingStateView(state: LoadingState<String>.failed(URLError(.notConnectedToInternet))) { value in
        Text(value)
    } retryAction: {}
}
