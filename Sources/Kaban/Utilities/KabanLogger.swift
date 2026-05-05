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

/// Structured metadata value for a ``KabanLogEntry``.
public enum KabanLogValue: Codable, Hashable, Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case date(Date)

    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    private enum ValueType: String, Codable {
        case string
        case int
        case double
        case bool
        case date
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ValueType.self, forKey: .type)
        switch type {
        case .string:
            self = .string(try container.decode(String.self, forKey: .value))
        case .int:
            self = .int(try container.decode(Int.self, forKey: .value))
        case .double:
            self = .double(try container.decode(Double.self, forKey: .value))
        case .bool:
            self = .bool(try container.decode(Bool.self, forKey: .value))
        case .date:
            self = .date(try container.decode(Date.self, forKey: .value))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .string(let value):
            try container.encode(ValueType.string, forKey: .type)
            try container.encode(value, forKey: .value)
        case .int(let value):
            try container.encode(ValueType.int, forKey: .type)
            try container.encode(value, forKey: .value)
        case .double(let value):
            try container.encode(ValueType.double, forKey: .type)
            try container.encode(value, forKey: .value)
        case .bool(let value):
            try container.encode(ValueType.bool, forKey: .type)
            try container.encode(value, forKey: .value)
        case .date(let value):
            try container.encode(ValueType.date, forKey: .type)
            try container.encode(value, forKey: .value)
        }
    }
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
    /// Log message.
    public let message: String
    /// Structured metadata for app-specific diagnostics.
    public let metadata: [String: KabanLogValue]
    /// Source file name.
    public let file: String
    /// Source line.
    public let line: Int
    /// Source function.
    public let function: String

    /// Creates a log entry.
    public init(
        id: UUID = UUID(),
        timestamp: Date,
        level: KabanLogLevel,
        category: String,
        message: String,
        metadata: [String: KabanLogValue] = [:],
        file: String,
        line: Int,
        function: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.level = level
        self.category = category
        self.message = message
        self.metadata = metadata
        self.file = file
        self.line = line
        self.function = function
    }
}

/// A page of persisted log entries.
public struct KabanLogPage: Sendable {
    /// Entries ordered newest first.
    public let entries: [KabanLogEntry]
    /// Offset for the next page when more entries exist.
    public let nextOffset: Int?

    /// Creates a log page.
    public init(entries: [KabanLogEntry], nextOffset: Int?) {
        self.entries = entries
        self.nextOffset = nextOffset
    }
}

/// Filter for persisted log entries.
public struct KabanLogFilter: Sendable {
    /// Levels to include.
    public var levels: Set<KabanLogLevel>?
    /// Categories to include.
    public var categories: Set<String>?
    /// Case-insensitive text query.
    public var query: String?
    /// Timestamp range to include.
    public var dateRange: ClosedRange<Date>?

    /// Filter matching every entry.
    public static let all = KabanLogFilter()

    /// Creates a log filter.
    public init(
        levels: Set<KabanLogLevel>? = nil,
        categories: Set<String>? = nil,
        query: String? = nil,
        dateRange: ClosedRange<Date>? = nil
    ) {
        self.levels = levels
        self.categories = categories
        self.query = query
        self.dateRange = dateRange
    }
}

/// File-backed logger for app diagnostics.
public struct KabanLogger: Sendable {
    private let writeEntry: @Sendable (KabanLogLevel, String, String, [String: KabanLogValue], String, Int, String) -> Void
    private let readEntries: @Sendable (KabanLogFilter, Int, Int) async -> KabanLogPage
    private let clearEntries: @Sendable (KabanLogFilter) async -> Void

    internal init(
        writeEntry: @escaping @Sendable (KabanLogLevel, String, String, [String: KabanLogValue], String, Int, String) -> Void,
        readEntries: @escaping @Sendable (KabanLogFilter, Int, Int) async -> KabanLogPage,
        clearEntries: @escaping @Sendable (KabanLogFilter) async -> Void
    ) {
        self.writeEntry = writeEntry
        self.readEntries = readEntries
        self.clearEntries = clearEntries
    }

    /// Creates a file-backed logger.
    public static func live(configuration: Configuration) -> KabanLogger {
        let store = KabanLogFileStore(configuration: configuration)

        return KabanLogger(
            writeEntry: { level, category, message, metadata, file, line, function in
                let fileName = file.split(separator: "/").last.map(String.init) ?? file
                let entry = KabanLogEntry(
                    timestamp: Date(),
                    level: level,
                    category: category,
                    message: message,
                    metadata: metadata,
                    file: fileName,
                    line: line,
                    function: function
                )

                store.write(entry)

                guard configuration.osLogEnabled else { return }
                let logger = Logger(subsystem: configuration.subsystem, category: category)
                let logMessage = entry.osLogText
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
            readEntries: { filter, limit, offset in
                await store.page(filter: filter, limit: limit, offset: offset)
            },
            clearEntries: { filter in
                await store.clear(filter: filter)
            }
        )
    }

    /// Writes a log entry.
    public func log(
        _ level: KabanLogLevel,
        category: String = "default",
        _ message: @autoclosure () -> String,
        metadata: [String: KabanLogValue] = [:],
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        writeEntry(level, category, message(), metadata, file, line, function)
    }

    /// Returns persisted entries ordered newest first.
    public func entries(
        filter: KabanLogFilter = .all,
        limit: Int = 100,
        offset: Int = 0
    ) async -> KabanLogPage {
        await readEntries(filter, limit, offset)
    }

    /// Clears persisted entries matching a filter.
    public func clear(filter: KabanLogFilter = .all) async {
        await clearEntries(filter)
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
        encoder.nonConformingFloatEncodingStrategy = .convertToString(
            positiveInfinity: "inf",
            negativeInfinity: "-inf",
            nan: "nan"
        )
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(
            positiveInfinity: "inf",
            negativeInfinity: "-inf",
            nan: "nan"
        )
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

    internal func page(filter: KabanLogFilter, limit: Int, offset: Int) async -> KabanLogPage {
        await withCheckedContinuation { continuation in
            queue.async { [self] in
                continuation.resume(returning: makePage(filter: filter, limit: limit, offset: offset))
            }
        }
    }

    internal func clear(filter: KabanLogFilter) async {
        await withCheckedContinuation { continuation in
            queue.async { [self] in
                let remainingEntries = readEntries().filter { !filter.matches($0) }
                writeEntries(remainingEntries)
                continuation.resume()
            }
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

    private func makePage(filter: KabanLogFilter, limit: Int, offset: Int) -> KabanLogPage {
        guard limit > 0 else {
            return KabanLogPage(entries: [], nextOffset: nil)
        }

        let safeOffset = max(offset, 0)
        let entries = readFilteredEntries(filter: filter)
        let pageEntries = Array(entries.dropFirst(safeOffset).prefix(limit))
        let nextOffset = safeOffset + pageEntries.count < entries.count
            ? safeOffset + pageEntries.count
            : nil

        return KabanLogPage(entries: pageEntries, nextOffset: nextOffset)
    }

    private func readFilteredEntries(filter: KabanLogFilter) -> [KabanLogEntry] {
        readEntries()
            .filter { filter.matches($0) }
            .sorted { lhs, rhs in
                if lhs.timestamp == rhs.timestamp {
                    return lhs.id.uuidString > rhs.id.uuidString
                }
                return lhs.timestamp > rhs.timestamp
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

private extension KabanLogFilter {
    func matches(_ entry: KabanLogEntry) -> Bool {
        if let levels, !levels.contains(entry.level) {
            return false
        }
        if let categories, !categories.contains(entry.category) {
            return false
        }
        if let dateRange, !dateRange.contains(entry.timestamp) {
            return false
        }
        if let query {
            let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedQuery.isEmpty, !entry.searchText.localizedCaseInsensitiveContains(trimmedQuery) {
                return false
            }
        }
        return true
    }
}

private extension KabanLogEntry {
    var osLogText: String {
        "[\(file):\(line)] \(message)"
    }

    var searchText: String {
        var values = [
            level.rawValue,
            category,
            message,
            file,
            function,
            String(line),
        ]
        values.append(contentsOf: metadata.sorted { $0.key < $1.key }.flatMap { key, value in
            [key, value.text]
        })
        return values.joined(separator: " ")
    }

}

private extension KabanLogValue {
    var text: String {
        switch self {
        case .string(let value):
            value
        case .int(let value):
            String(value)
        case .double(let value):
            String(value)
        case .bool(let value):
            String(value)
        case .date(let value):
            value.formatted(.iso8601)
        }
    }
}
