import Foundation
import OSLog

/// Severity for a ``KabanLogEntry``.
public enum KabanLogLevel: String, CaseIterable, Codable, Hashable, Sendable {
    /// Verbose diagnostic information.
    case debug
    /// General informational messages.
    case info
    /// Noteworthy runtime events.
    case notice
    /// Recoverable or suspicious conditions.
    case warning
    /// Failures and unrecoverable conditions.
    case error
}

/// A single persisted log entry.
public struct KabanLogEntry: Codable, Hashable, Identifiable, Sendable {
    /// Stable identifier for list rendering and persistence.
    public let id: UUID
    /// Time when the entry was created.
    public let timestamp: Date
    /// Entry severity.
    public let level: KabanLogLevel
    /// Caller-defined category.
    public let category: String
    /// Source file name.
    public let file: String
    /// Source line.
    public let line: Int
    /// Source function.
    public let function: String
    /// Log message.
    public let message: String

    /// Creates a log entry.
    public init(
        id: UUID = UUID(),
        timestamp: Date,
        level: KabanLogLevel,
        category: String,
        file: String,
        line: Int,
        function: String,
        message: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.level = level
        self.category = category
        self.file = file
        self.line = line
        self.function = function
        self.message = message
    }
}

/// File-backed logger for app diagnostics.
public struct KabanLogger: Sendable {
    private let writeEntry: @Sendable (KabanLogLevel, String, String, String, Int, String) -> Void
    private let readEntries: @Sendable () -> [KabanLogEntry]
    private let clearEntries: @Sendable () async -> Void
    private let pruneEntries: @Sendable () -> Void

    internal init(
        writeEntry: @escaping @Sendable (KabanLogLevel, String, String, String, Int, String) -> Void,
        readEntries: @escaping @Sendable () -> [KabanLogEntry],
        clearEntries: @escaping @Sendable () async -> Void,
        pruneEntries: @escaping @Sendable () -> Void
    ) {
        self.writeEntry = writeEntry
        self.readEntries = readEntries
        self.clearEntries = clearEntries
        self.pruneEntries = pruneEntries
    }

    /// Creates a file-backed logger.
    public static func live(configuration: Configuration) -> KabanLogger {
        let store = KabanLogFileStore(configuration: configuration)

        return KabanLogger(
            writeEntry: { level, category, message, file, line, function in
                let fileName = file.split(separator: "/").last.map(String.init) ?? file
                let entry = KabanLogEntry(
                    timestamp: Date(),
                    level: level,
                    category: category,
                    file: fileName,
                    line: line,
                    function: function,
                    message: message
                )

                store.write(entry)

                guard configuration.osLogEnabled else { return }
                let logger = Logger(subsystem: configuration.subsystem, category: category)
                let logMessage = "[\(fileName):\(line)] \(message)"
                switch level {
                case .debug:
                    logger.debug("\(logMessage)")
                case .info:
                    logger.info("\(logMessage)")
                case .notice:
                    logger.notice("\(logMessage)")
                case .warning:
                    logger.warning("\(logMessage)")
                case .error:
                    logger.error("\(logMessage)")
                }
            },
            readEntries: {
                store.readAll()
            },
            clearEntries: {
                await store.clear()
            },
            pruneEntries: {
                store.prune()
            }
        )
    }

    /// Writes a log entry.
    public func log(
        _ level: KabanLogLevel,
        category: String = "default",
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        writeEntry(level, category, message(), file, line, function)
    }

    /// Returns all persisted entries in write order.
    public func entries() -> [KabanLogEntry] {
        readEntries()
    }

    /// Clears all persisted entries.
    public func clear() async {
        await clearEntries()
    }

    /// Removes entries older than the configured retention duration.
    public func prune() {
        pruneEntries()
    }
}

extension KabanLogger {
    /// File-backed logger configuration.
    public struct Configuration: Sendable {
        /// OSLog subsystem.
        public let subsystem: String
        /// Directory containing the log file.
        public let storageDirectoryURL: URL
        /// Log file name.
        public let fileName: String
        /// Entry retention duration in seconds. Pass `nil` to disable pruning.
        public let retentionDuration: TimeInterval?
        /// Whether entries are also written to OSLog.
        public let osLogEnabled: Bool

        /// Creates a logger configuration.
        public init(
            subsystem: String,
            storageDirectoryURL: URL = Self.defaultStorageDirectoryURL(),
            fileName: String = "kaban.log",
            retentionDuration: TimeInterval? = 60 * 60 * 24 * 3,
            osLogEnabled: Bool = true
        ) {
            self.subsystem = subsystem
            self.storageDirectoryURL = storageDirectoryURL
            self.fileName = fileName
            self.retentionDuration = retentionDuration
            self.osLogEnabled = osLogEnabled
        }

        /// Default storage directory for Kaban logs.
        public static func defaultStorageDirectoryURL() -> URL {
            let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? FileManager.default.temporaryDirectory
            return baseURL.appendingPathComponent("Kaban/Logs", isDirectory: true)
        }
    }
}

extension KabanLogger {
    internal static func preview(entries: [KabanLogEntry]) -> KabanLogger {
        KabanLogger(
            writeEntry: { _, _, _, _, _, _ in },
            readEntries: { entries },
            clearEntries: {},
            pruneEntries: {}
        )
    }
}

private final class KabanLogFileStore: @unchecked Sendable {
    private static let pruneInterval: TimeInterval = 60 * 60

    private let queue: DispatchQueue
    private let configuration: KabanLogger.Configuration
    private let logFileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private var lastPruneDate: Date?

    internal init(configuration: KabanLogger.Configuration) {
        self.queue = DispatchQueue(label: "com.kaban.logger.file-store")
        self.configuration = configuration
        self.logFileURL = configuration.storageDirectoryURL.appendingPathComponent(configuration.fileName)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    internal func write(_ entry: KabanLogEntry) {
        queue.async { [self] in
            guard let data = try? encoder.encode(entry),
                  let line = String(data: data, encoding: .utf8) else { return }
            pruneIfNeeded(now: entry.timestamp)
            appendLine(line)
        }
    }

    internal func readAll() -> [KabanLogEntry] {
        queue.sync { [self] in
            readEntries()
        }
    }

    internal func clear() async {
        await withCheckedContinuation { continuation in
            queue.async { [self] in
                try? FileManager.default.createDirectory(
                    at: configuration.storageDirectoryURL,
                    withIntermediateDirectories: true
                )
                try? Data().write(to: logFileURL)
                continuation.resume()
            }
        }
    }

    internal func prune() {
        guard configuration.retentionDuration != nil else { return }
        queue.sync { [self] in
            let now = Date()
            lastPruneDate = now
            pruneEntries(now: now)
        }
    }

    private func appendLine(_ line: String) {
        try? FileManager.default.createDirectory(
            at: configuration.storageDirectoryURL,
            withIntermediateDirectories: true
        )

        let lineData = Data((line + "\n").utf8)
        if FileManager.default.fileExists(atPath: logFileURL.path) {
            guard let handle = try? FileHandle(forWritingTo: logFileURL) else { return }
            handle.seekToEndOfFile()
            handle.write(lineData)
            handle.closeFile()
        } else {
            try? lineData.write(to: logFileURL)
        }
    }

    private func readEntries() -> [KabanLogEntry] {
        guard let data = try? Data(contentsOf: logFileURL),
              let content = String(data: data, encoding: .utf8) else { return [] }
        return content
            .split(separator: "\n")
            .compactMap { line in
                try? decoder.decode(KabanLogEntry.self, from: Data(line.utf8))
            }
    }

    private func pruneIfNeeded(now: Date) {
        guard configuration.retentionDuration != nil else { return }
        if let lastPruneDate, now.timeIntervalSince(lastPruneDate) < Self.pruneInterval {
            return
        }
        lastPruneDate = now
        pruneEntries(now: now)
    }

    private func pruneEntries(now: Date) {
        guard let retentionDuration = configuration.retentionDuration else { return }
        let cutoff = now.addingTimeInterval(-retentionDuration)
        let entries = readEntries().filter { $0.timestamp >= cutoff }
        writeEntries(entries)
    }

    private func writeEntries(_ entries: [KabanLogEntry]) {
        try? FileManager.default.createDirectory(
            at: configuration.storageDirectoryURL,
            withIntermediateDirectories: true
        )

        let lines = entries.compactMap { entry -> String? in
            guard let data = try? encoder.encode(entry) else { return nil }
            return String(data: data, encoding: .utf8)
        }
        let content = lines.joined(separator: "\n") + (lines.isEmpty ? "" : "\n")
        try? Data(content.utf8).write(to: logFileURL)
    }
}
