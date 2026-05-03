import Foundation
import Testing
@testable import Kaban

@Test
func loggerWritesAndReadsEntries() {
    let context = try! makeLoggerContext()

    context.logger.log(.notice, category: "app", "Application started", file: "App.swift", function: "start()", line: 12)

    let entries = context.logger.entries()

    #expect(entries.count == 1)
    #expect(entries[0].level == .notice)
    #expect(entries[0].category == "app")
    #expect(entries[0].message == "Application started")
    #expect(entries[0].file == "App.swift")
    #expect(entries[0].function == "start()")
    #expect(entries[0].line == 12)
}

@Test
func loggerClearsEntries() async {
    let context = try! makeLoggerContext()
    context.logger.log(.error, "Failed")

    await context.logger.clear()

    #expect(context.logger.entries().isEmpty)
}

@Test
func loggerPrunesEntriesOlderThanRetentionDuration() throws {
    let context = try makeLoggerContext(retentionDuration: 60)
    let oldEntry = KabanLogEntry(
        timestamp: Date().addingTimeInterval(-120),
        level: .debug,
        category: "old",
        file: "Old.swift",
        line: 1,
        function: "old()",
        message: "Old"
    )
    let currentEntry = KabanLogEntry(
        timestamp: Date(),
        level: .info,
        category: "current",
        file: "Current.swift",
        line: 2,
        function: "current()",
        message: "Current"
    )
    try writeRawEntries([oldEntry, currentEntry], to: context.logFileURL)

    context.logger.prune()

    let entries = context.logger.entries()
    #expect(entries.map(\.message) == ["Current"])
}

@Test
func loggerPrunesEntriesAutomaticallyWhenWriting() throws {
    let context = try makeLoggerContext(retentionDuration: 60)
    let oldEntry = KabanLogEntry(
        timestamp: Date().addingTimeInterval(-120),
        level: .debug,
        category: "old",
        file: "Old.swift",
        line: 1,
        function: "old()",
        message: "Old"
    )
    try writeRawEntries([oldEntry], to: context.logFileURL)

    context.logger.log(.info, "Current")

    let entries = context.logger.entries()
    #expect(entries.map(\.message) == ["Current"])
}

@Test
func loggerIgnoresInvalidJSONLines() throws {
    let context = try makeLoggerContext()
    let validEntry = KabanLogEntry(
        timestamp: Date(),
        level: .warning,
        category: "test",
        file: "Test.swift",
        line: 3,
        function: "test()",
        message: "Valid"
    )
    try writeRawLines(["not-json", encodedLine(validEntry)], to: context.logFileURL)

    let entries = context.logger.entries()

    #expect(entries.count == 1)
    #expect(entries[0].message == "Valid")
}

private struct LoggerContext {
    let logger: KabanLogger
    let logFileURL: URL
}

private func makeLoggerContext(retentionDuration: TimeInterval? = 60 * 60 * 24 * 3) throws -> LoggerContext {
    let directoryURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("KabanLoggerTests", isDirectory: true)
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let fileName = "test.log"
    let logger = KabanLogger.live(
        configuration: KabanLogger.Configuration(
            subsystem: "com.kaban.tests",
            storageDirectoryURL: directoryURL,
            fileName: fileName,
            retentionDuration: retentionDuration,
            osLogEnabled: false
        )
    )
    return LoggerContext(
        logger: logger,
        logFileURL: directoryURL.appendingPathComponent(fileName)
    )
}

private func writeRawEntries(_ entries: [KabanLogEntry], to url: URL) throws {
    try writeRawLines(entries.map(encodedLine), to: url)
}

private func writeRawLines(_ lines: [String], to url: URL) throws {
    try FileManager.default.createDirectory(
        at: url.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )
    let content = lines.joined(separator: "\n") + "\n"
    try Data(content.utf8).write(to: url)
}

private func encodedLine(_ entry: KabanLogEntry) -> String {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let data = try! encoder.encode(entry)
    return String(data: data, encoding: .utf8)!
}
