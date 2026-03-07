import SwiftUI

public struct KabanSecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.kabanAccentColor) private var accentColor

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .kabanTextStyle(.bodyLarge(weight: .bold), color: isEnabled ? accentColor : .textDisabled)
            .padding(.vertical, 12)
            .padding(.horizontal, 12)

            .background(isEnabled ? KabanColor.surfaceNeutral.color : KabanColor.surfaceDisabled.color)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

extension ButtonStyle where Self == KabanSecondaryButtonStyle {
    public static var kabanSecondary: KabanSecondaryButtonStyle { .init() }
}

#Preview {
    VStack(spacing: 16) {
        Button("Enabled") {}
            .buttonStyle(.kabanSecondary)

        Button("Disabled") {}
            .buttonStyle(.kabanSecondary)
            .disabled(true)
    }
    .padding()
}

#Preview("Accent: Blue") {
    VStack(spacing: 16) {
        Button("Enabled") {}
            .buttonStyle(.kabanSecondary)

        Button("Disabled") {}
            .buttonStyle(.kabanSecondary)
            .disabled(true)
    }
    .padding()
    .environment(\.kabanAccentColor, .accentBlue)
}
