import SwiftUI

public struct AsyncButton<Label: View>: View {
    private let action: () async -> Void
    private let label: Label

    @State private var isRunning = false
    @State private var task: Task<Void, Never>?

    public init(
        action: @escaping () async -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.label = label()
    }

    public var body: some View {
        Button {
            isRunning = true
            task = Task {
                defer {
                    isRunning = false
                    task = nil
                }
                await action()
            }
        } label: {
            label
                .opacity(isRunning ? 0 : 1)
                .overlay {
                    if isRunning {
                        ProgressView()
                    }
                }
        }
        .disabled(isRunning)
        .onDisappear {
            task?.cancel()
        }
    }
}

#Preview {
    AsyncButton {
        try? await Task.sleep(for: .seconds(2))
    } label: {
        Text("Tap me")
    }
    .buttonStyle(.kabanPrimary)
    .padding()
}
