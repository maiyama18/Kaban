import SwiftUI
import UIKit

/// Displays entries from a ``KabanLogger``.
public struct KabanLogViewerScreen: View {
    private let logger: KabanLogger

    @State private var entries: [KabanLogEntry] = []
    @State private var query = ""
    @State private var showsClearConfirmation = false

    private var filteredEntries: [KabanLogEntry] {
        guard !query.isEmpty else { return entries }
        return entries.filter { entry in
            entry.message.localizedCaseInsensitiveContains(query)
                || entry.category.localizedCaseInsensitiveContains(query)
                || entry.file.localizedCaseInsensitiveContains(query)
                || entry.function.localizedCaseInsensitiveContains(query)
                || entry.level.rawValue.localizedCaseInsensitiveContains(query)
        }
    }

    private var logText: String {
        filteredEntries.map(\.formattedLogText).joined(separator: "\n")
    }

    /// Creates a log viewer.
    public init(logger: KabanLogger) {
        self.logger = logger
    }

    public var body: some View {
        Group {
            if entries.isEmpty {
                ContentUnavailableView(
                    .kabanLogViewerNoLogs,
                    systemImage: "doc.text"
                )
            } else {
                List(filteredEntries.reversed()) { entry in
                    KabanLogEntryRow(entry: entry)
                }
                .listStyle(.plain)
            }
        }
        .searchable(text: $query, prompt: Text(.kabanLogViewerSearchLogs))
        .navigationTitle(.kabanLogViewerTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ShareLink(item: logText) {
                    Image(systemName: "square.and.arrow.up")
                }
                .disabled(filteredEntries.isEmpty)
            }
            ToolbarSpacer(.fixed, placement: .primaryAction)
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showsClearConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
                .disabled(entries.isEmpty)
            }
        }
        .alert(
            .kabanLogViewerClearLogs,
            isPresented: $showsClearConfirmation
        ) {
            Button(role: .destructive) {
                Task { await clearLogs() }
            } label: {
                Text(.kabanLogViewerClearLogs)
            }
            Button(role: .cancel) {
            } label: {
                Text(.kabanLogViewerCancel)
            }
        } message: {
            Text(.kabanLogViewerClearLogsConfirmation)
        }
        .task {
            reload()
        }
    }

    private func reload() {
        entries = logger.entries()
    }

    private func clearLogs() async {
        await logger.clear()
        entries = []
    }
}

private extension KabanLogEntry {
    var formattedLogText: String {
        "[\(timestamp.formatted(.iso8601))] [\(level.rawValue.uppercased())] [\(category)] \(file):\(line) \(function) - \(message)"
    }
}

private struct KabanLogEntryRow: View {
    let entry: KabanLogEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(entry.level.rawValue.uppercased())
                    .kabanTextStyle(.captionRegular(weight: .bold), color: levelColor)
                Text(entry.category)
                    .kabanTextStyle(.captionRegular(), color: .textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(entry.timestamp, format: .dateTime.hour().minute().second())
                    .kabanTextStyle(.captionRegular(), color: .textSecondary)
            }
            Text(entry.message)
                .kabanTextStyle(.bodySmall(), color: .textPrimary)
                .lineLimit(3)
            Text("\(entry.file):\(entry.line)")
                .kabanTextStyle(.captionRegular(), color: .textSecondary)
        }
        .padding(.vertical, 2)
        .contextMenu {
            Button {
                UIPasteboard.general.string = entry.message
            } label: {
                Label(.kabanLogViewerCopyMessage, systemImage: "doc.on.doc")
            }
        }
    }

    private var levelColor: KabanColor {
        switch entry.level {
        case .debug:
            .textSecondary
        case .info, .notice:
            .textPrimary
        case .warning:
            .accentYellow
        case .error:
            .textDanger
        }
    }
}

#Preview {
    NavigationStack {
        KabanLogViewerScreen(
            logger: .preview(entries: [
                KabanLogEntry(
                    timestamp: Date(),
                    level: .notice,
                    category: "default",
                    file: "ContentView.swift",
                    line: 42,
                    function: "load()",
                    message: "Loaded user settings"
                ),
                KabanLogEntry(
                    timestamp: Date(),
                    level: .error,
                    category: "network",
                    file: "APIClient.swift",
                    line: 128,
                    function: "request()",
                    message: "Request failed with status code 500"
                ),
            ])
        )
    }
}
