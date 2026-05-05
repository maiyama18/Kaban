import Foundation
import Testing
@testable import Kaban

@Test
func loggerWritesAndReadsEntries() async {
    let context = try! makeLoggerContext()

    context.logger.log(
        .notice,
        category: "app",
        "Application started",
        metadata: [
            "coldStart": .bool(true),
            "launchCount": .int(3),
        ],
        file: "App.swift",
        function: "start()",
        line: 12
    )

    let page = await context.logger.entries()

    #expect(page.entries.count == 1)
    #expect(page.nextOffset == nil)
    #expect(page.entries[0].level == .notice)
    #expect(page.entries[0].category == "app")
    #expect(page.entries[0].message == "Application started")
    #expect(page.entries[0].metadata == [
        "coldStart": .bool(true),
        "launchCount": .int(3),
    ])
    #expect(page.entries[0].file == "App.swift")
    #expect(page.entries[0].function == "start()")
    #expect(page.entries[0].line == 12)
}

@Test
func loggerReturnsNewestEntriesFirst() async throws {
    let context = try makeLoggerContext()
    try writeRawEntries(
        [
            makeEntry(timestamp: Date(timeIntervalSince1970: 1), message: "Old"),
            makeEntry(timestamp: Date(timeIntervalSince1970: 3), message: "New"),
            makeEntry(timestamp: Date(timeIntervalSince1970: 2), message: "Middle"),
        ],
        to: context.logFileURL
    )

    let page = await context.logger.entries(limit: 10)

    #expect(page.entries.map(\.message) == ["New", "Middle", "Old"])
    #expect(page.nextOffset == nil)
}

@Test
func loggerPagesEntriesByOffsetAndLimit() async throws {
    let context = try makeLoggerContext()
    try writeRawEntries(
        [
            makeEntry(timestamp: Date(timeIntervalSince1970: 1), message: "1"),
            makeEntry(timestamp: Date(timeIntervalSince1970: 2), message: "2"),
            makeEntry(timestamp: Date(timeIntervalSince1970: 3), message: "3"),
            makeEntry(timestamp: Date(timeIntervalSince1970: 4), message: "4"),
            makeEntry(timestamp: Date(timeIntervalSince1970: 5), message: "5"),
        ],
        to: context.logFileURL
    )

    let firstPage = await context.logger.entries(limit: 2, offset: 0)
    let secondPage = await context.logger.entries(limit: 2, offset: firstPage.nextOffset ?? -1)
    let thirdPage = await context.logger.entries(limit: 2, offset: secondPage.nextOffset ?? -1)

    #expect(firstPage.entries.map(\.message) == ["5", "4"])
    #expect(firstPage.nextOffset == 2)
    #expect(secondPage.entries.map(\.message) == ["3", "2"])
    #expect(secondPage.nextOffset == 4)
    #expect(thirdPage.entries.map(\.message) == ["1"])
    #expect(thirdPage.nextOffset == nil)
}

@Test
func loggerFiltersEntries() async throws {
    let context = try makeLoggerContext()
    let baseDate = Date(timeIntervalSince1970: 1_000)
    try writeRawEntries(
        [
            makeEntry(
                timestamp: baseDate,
                level: .notice,
                category: "location",
                message: "Accepted location",
                metadata: [
                    "source": .string("gps"),
                    "horizontalAccuracy": .double(8.5),
                    "mocked": .bool(false),
                ],
                file: "LocationStore.swift",
                function: "accept()"
            ),
            makeEntry(
                timestamp: baseDate.addingTimeInterval(60),
                level: .warning,
                category: "location",
                message: "Rejected location",
                metadata: [
                    "reason": .string("stale"),
                ],
                file: "LocationStore.swift",
                function: "reject()"
            ),
            makeEntry(
                timestamp: baseDate.addingTimeInterval(120),
                level: .error,
                category: "network",
                message: "Request failed",
                metadata: [
                    "status": .int(500),
                ],
                file: "APIClient.swift",
                function: "request()"
            ),
        ],
        to: context.logFileURL
    )

    let levelPage = await context.logger.entries(filter: .init(levels: [.warning, .error]))
    let categoryPage = await context.logger.entries(filter: .init(categories: ["location"]))
    let metadataQueryPage = await context.logger.entries(filter: .init(query: "horizontalAccuracy"))
    let valueQueryPage = await context.logger.entries(filter: .init(query: "500"))
    let dateRangePage = await context.logger.entries(
        filter: .init(dateRange: baseDate.addingTimeInterval(30)...baseDate.addingTimeInterval(90))
    )

    #expect(levelPage.entries.map(\.message) == ["Request failed", "Rejected location"])
    #expect(categoryPage.entries.map(\.message) == ["Rejected location", "Accepted location"])
    #expect(metadataQueryPage.entries.map(\.message) == ["Accepted location"])
    #expect(valueQueryPage.entries.map(\.message) == ["Request failed"])
    #expect(dateRangePage.entries.map(\.message) == ["Rejected location"])
}

@Test
func loggerClearsEntriesMatchingFilter() async throws {
    let context = try makeLoggerContext()
    try writeRawEntries(
        [
            makeEntry(level: .notice, category: "location", message: "Location accepted"),
            makeEntry(level: .warning, category: "location", message: "Location rejected"),
            makeEntry(level: .error, category: "network", message: "Network failed"),
        ],
        to: context.logFileURL
    )

    await context.logger.clear(filter: .init(categories: ["location"]))

    let page = await context.logger.entries()
    #expect(page.entries.map(\.message) == ["Network failed"])
}

@Test
func loggerClearsAllEntries() async {
    let context = try! makeLoggerContext()
    context.logger.log(.error, "Failed")

    await context.logger.clear()

    let page = await context.logger.entries()
    #expect(page.entries.isEmpty)
}

@Test
func loggerEncodesAndDecodesMetadataValues() async throws {
    let context = try makeLoggerContext()
    let date = Date(timeIntervalSince1970: 1_234)
    let entry = makeEntry(
        message: "Metadata",
        metadata: [
            "string": .string("value"),
            "int": .int(1),
            "double": .double(1.5),
            "bool": .bool(true),
            "date": .date(date),
        ]
    )
    try writeRawEntries([entry], to: context.logFileURL)

    let page = await context.logger.entries()

    #expect(page.entries[0].metadata["string"] == .string("value"))
    #expect(page.entries[0].metadata["int"] == .int(1))
    #expect(page.entries[0].metadata["double"] == .double(1.5))
    #expect(page.entries[0].metadata["bool"] == .bool(true))
    #expect(page.entries[0].metadata["date"] == .date(date))
}

@Test
func loggerWritesNonConformingDoubleMetadataValues() async throws {
    let context = try makeLoggerContext()

    context.logger.log(
        .notice,
        "Non-conforming doubles",
        metadata: [
            "nan": .double(.nan),
            "positiveInfinity": .double(.infinity),
            "negativeInfinity": .double(-.infinity),
        ]
    )

    let page = await context.logger.entries()

    #expect(page.entries.count == 1)
    guard case .double(let nan) = page.entries[0].metadata["nan"] else {
        Issue.record("Expected nan metadata")
        return
    }
    guard case .double(let positiveInfinity) = page.entries[0].metadata["positiveInfinity"] else {
        Issue.record("Expected positiveInfinity metadata")
        return
    }
    guard case .double(let negativeInfinity) = page.entries[0].metadata["negativeInfinity"] else {
        Issue.record("Expected negativeInfinity metadata")
        return
    }
    #expect(nan.isNaN)
    #expect(positiveInfinity == .infinity)
    #expect(negativeInfinity == -.infinity)
}

@Test
func loggerPrunesEntriesAutomaticallyWhenWriting() async throws {
    let context = try makeLoggerContext(retentionDuration: 60)
    let oldEntry = makeEntry(
        timestamp: Date().addingTimeInterval(-120),
        level: .debug,
        category: "old",
        message: "Old",
        file: "Old.swift",
        line: 1,
        function: "old()"
    )
    try writeRawEntries([oldEntry], to: context.logFileURL)

    context.logger.log(.info, "Current")

    let page = await context.logger.entries()
    #expect(page.entries.map(\.message) == ["Current"])
}

@Test
func loggerIgnoresInvalidJSONLines() async throws {
    let context = try makeLoggerContext()
    let validEntry = makeEntry(
        level: .warning,
        category: "test",
        message: "Valid",
        file: "Test.swift",
        line: 3,
        function: "test()"
    )
    try writeRawLines(["not-json", encodedLine(validEntry)], to: context.logFileURL)

    let page = await context.logger.entries()

    #expect(page.entries.count == 1)
    #expect(page.entries[0].message == "Valid")
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

private func makeEntry(
    timestamp: Date = Date(),
    level: KabanLogLevel = .notice,
    category: String = "default",
    message: String,
    metadata: [String: KabanLogValue] = [:],
    file: String = "Test.swift",
    line: Int = 1,
    function: String = "test()"
) -> KabanLogEntry {
    KabanLogEntry(
        timestamp: timestamp,
        level: level,
        category: category,
        message: message,
        metadata: metadata,
        file: file,
        line: line,
        function: function
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
