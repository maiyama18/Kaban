/// Represents the lifecycle of loading a sendable value.
public enum LoadingState<T: Sendable>: Sendable {
    /// No loading request has started.
    case empty
    /// A loading request is currently running.
    case loading
    /// Loading finished successfully.
    case loaded(T)
    /// Loading finished with an error.
    case failed(Error)

    /// Whether the state is ``loading``.
    public var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    /// Transitions ``empty`` to ``loading`` and leaves every other state unchanged.
    public mutating func startLoadingIfEmpty() {
        if case .empty = self {
            self = .loading
        }
    }
}
