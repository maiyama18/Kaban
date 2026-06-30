import SwiftUI

/// Filled primary button style using the current `kabanAccentColor`.
public struct KabanPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.kabanAccentColor) private var accentColor
    private let buttonShape: KabanButtonShape
    private let verticalPadding: CGFloat

    /// Creates a primary button style.
    public init(shape: KabanButtonShape, verticalPadding: CGFloat = 16) {
        self.buttonShape = shape
        self.verticalPadding = verticalPadding
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .kabanTextStyle(.bodyLarge(weight: .bold), color: isEnabled ? .textInvertedPrimary : .textDisabled)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, 12)
            .background(isEnabled ? accentColor.color : KabanColor.surfaceDisabled.color)
            .clipShape(buttonShape.shape)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

extension ButtonStyle where Self == KabanPrimaryButtonStyle {
    /// Filled primary Kaban button style.
    public static func kabanPrimary(shape: KabanButtonShape, verticalPadding: CGFloat = 16) -> KabanPrimaryButtonStyle {
        .init(shape: shape, verticalPadding: verticalPadding)
    }
}

#Preview {
    VStack(spacing: 16) {
        Button("Rounded Rectangle") {}
            .buttonStyle(.kabanPrimary(shape: .roundedRectangle))

        Button("Capsule") {}
            .buttonStyle(.kabanPrimary(shape: .capsule))

        Button("Disabled") {}
            .buttonStyle(.kabanPrimary(shape: .roundedRectangle))
            .disabled(true)
    }
    .padding()
}

#Preview("Accent: Blue") {
    VStack(spacing: 16) {
        Button("Rounded Rectangle") {}
            .buttonStyle(.kabanPrimary(shape: .roundedRectangle))

        Button("Capsule") {}
            .buttonStyle(.kabanPrimary(shape: .capsule))

        Button("Disabled") {}
            .buttonStyle(.kabanPrimary(shape: .roundedRectangle))
            .disabled(true)
    }
    .padding()
    .environment(\.kabanAccentColor, .accentBlue)
}
