import Testing
@testable import Kaban

private enum LoadingStateTestError: Error {
    case failure
}

@Test
func isLoadingReturnsTrueOnlyForLoadingState() {
    #expect(LoadingState<String>.empty.isLoading == false)
    #expect(LoadingState<String>.loading.isLoading)
    #expect(LoadingState.loaded("value").isLoading == false)
    #expect(LoadingState<String>.failed(LoadingStateTestError.failure).isLoading == false)
}

@Test
func startLoadingIfEmptyTransitionsEmptyStateToLoading() {
    var state = LoadingState<String>.empty

    state.startLoadingIfEmpty()

    #expect(state.isLoading)
}

@Test
func startLoadingIfEmptyPreservesNonEmptyStates() {
    var loadingState = LoadingState<String>.loading
    loadingState.startLoadingIfEmpty()
    #expect(loadingState.isLoading)

    var loadedState = LoadingState.loaded("value")
    loadedState.startLoadingIfEmpty()
    guard case .loaded(let value) = loadedState else {
        Issue.record("Expected loaded state")
        return
    }
    #expect(value == "value")

    var failedState = LoadingState<String>.failed(LoadingStateTestError.failure)
    failedState.startLoadingIfEmpty()
    guard case .failed = failedState else {
        Issue.record("Expected failed state")
        return
    }
}

@Test
func loadingStateConformsToSendableWhenValueIsSendable() {
    requireSendable(LoadingState<String>.empty)
    requireSendable(LoadingState.loaded("value"))
}

private func requireSendable<T: Sendable>(_: T) {}
