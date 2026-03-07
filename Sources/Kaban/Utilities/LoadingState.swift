public enum LoadingState<T: Sendable>: Sendable {
    case empty
    case loading
    case loaded(T)
    case failed(Error)

    public var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    public mutating func startLoadingIfEmpty() {
        if case .empty = self {
            self = .loading
        }
    }
}
