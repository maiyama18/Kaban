import SwiftUI

public struct KabanPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.kabanAccentColor) private var accentColor

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .kabanTextStyle(.bodyLarge(weight: .bold), color: .textInvertedPrimary)
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(isEnabled ? accentColor : KabanColor.surfaceDisabled.color)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

extension ButtonStyle where Self == KabanPrimaryButtonStyle {
    public static var kabanPrimary: KabanPrimaryButtonStyle { .init() }
}

#Preview {
    VStack(spacing: 16) {
        Button("Enabled") {}
            .buttonStyle(.kabanPrimary)

        Button("Disabled") {}
            .buttonStyle(.kabanPrimary)
            .disabled(true)
    }
    .padding()
}
