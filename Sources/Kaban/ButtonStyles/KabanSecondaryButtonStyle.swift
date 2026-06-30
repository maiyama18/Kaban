import SwiftUI

/// Neutral secondary button style using the current `kabanAccentColor` for text.
public struct KabanSecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.kabanAccentColor) private var accentColor
    private let buttonShape: KabanButtonShape
    private let verticalPadding: CGFloat

    /// Creates a secondary button style.
    public init(shape: KabanButtonShape, verticalPadding: CGFloat = 16) {
        self.buttonShape = shape
        self.verticalPadding = verticalPadding
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .kabanTextStyle(.bodyLarge(weight: .bold), color: isEnabled ? accentColor : .textDisabled)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, 12)
            .background(isEnabled ? KabanColor.surfaceNeutral.color : KabanColor.surfaceDisabled.color)
            .clipShape(buttonShape.shape)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

extension ButtonStyle where Self == KabanSecondaryButtonStyle {
    /// Neutral secondary Kaban button style.
    public static func kabanSecondary(shape: KabanButtonShape, verticalPadding: CGFloat = 16) -> KabanSecondaryButtonStyle {
        .init(shape: shape, verticalPadding: verticalPadding)
    }
}

#Preview {
    VStack(spacing: 16) {
        Button("Rounded Rectangle") {}
            .buttonStyle(.kabanSecondary(shape: .roundedRectangle))

        Button("Capsule") {}
            .buttonStyle(.kabanSecondary(shape: .capsule))

        Button("Disabled") {}
            .buttonStyle(.kabanSecondary(shape: .roundedRectangle))
            .disabled(true)
    }
    .padding()
}

#Preview("Accent: Blue") {
    VStack(spacing: 16) {
        Button("Rounded Rectangle") {}
            .buttonStyle(.kabanSecondary(shape: .roundedRectangle))

        Button("Capsule") {}
            .buttonStyle(.kabanSecondary(shape: .capsule))

        Button("Disabled") {}
            .buttonStyle(.kabanSecondary(shape: .roundedRectangle))
            .disabled(true)
    }
    .padding()
    .environment(\.kabanAccentColor, .accentBlue)
}
