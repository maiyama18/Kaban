import SwiftUI

public struct PlaceholderTextEditor: View {
    @Binding private var text: String
    private let placeholder: String

    public init(text: Binding<String>, placeholder: String) {
        self._text = text
        self.placeholder = placeholder
    }

    public var body: some View {
        TextEditor(text: $text)
            .scrollContentBackground(.hidden)
            .overlay(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(.placeholder)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .allowsHitTesting(false)
                }
            }
    }
}

#Preview {
    @Previewable @State var text = ""
    PlaceholderTextEditor(text: $text, placeholder: "Enter text here...")
        .padding()
        .frame(height: 200)
}
