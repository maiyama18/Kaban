public struct TimeoutError: Error {}

public func withRetry<T: Sendable>(
    count: Int,
    operation: @Sendable @escaping () async throws -> T
) async rethrows -> T {
    for _ in 0..<(count - 1) {
        guard !Task.isCancelled else { break }
        do {
            return try await operation()
        } catch is CancellationError {
            break
        } catch {}
    }
    return try await operation()
}

public func withTimeout<T: Sendable>(
    for duration: Duration,
    operation: @Sendable @escaping () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T?.self) { group in
        group.addTask {
            try await Task.sleep(for: duration)
            return nil
        }

        group.addTask {
            try await operation()
        }

        guard let result = try await group.next() else {
            throw TimeoutError()
        }
        group.cancelAll()
        if let result {
            return result
        } else {
            throw TimeoutError()
        }
    }
}
