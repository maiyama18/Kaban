/// Error thrown when ``withTimeout(for:operation:)`` reaches its duration before the operation completes.
public struct TimeoutError: Error {}

/// Runs an async operation until it succeeds or the retry count is exhausted.
///
/// Cancellation stops the retry loop. The operation is still called once after
/// the loop, so the final error remains the operation's own error.
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

/// Runs an async operation and throws ``TimeoutError`` if it does not finish within the given duration.
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
