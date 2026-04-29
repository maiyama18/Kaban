import SwiftUI

/// Font weight token used by Kaban text styles.
public enum KabanFontWeight {
    /// Bold font weight.
    case bold
    /// Semibold font weight.
    case semibold
    /// Regular font weight.
    case regular

    internal var swiftUIFontWeight: Font.Weight {
        switch self {
        case .bold: .bold
        case .semibold: .semibold
        case .regular: .regular
        }
    }
}

/// Dynamic Type-aware font token used by Kaban components.
public struct KabanFont: Sendable {
    internal let size: CGFloat
    internal let relativeTo: Font.TextStyle
    internal let weight: Font.Weight
    internal let lineSpacing: CGFloat

    private init(size: CGFloat, relativeTo: Font.TextStyle, weight: KabanFontWeight, lineSpacing: CGFloat) {
        self.size = size
        self.relativeTo = relativeTo
        self.weight = weight.swiftUIFontWeight
        self.lineSpacing = lineSpacing
    }

    /// Large title style.
    public static func titleLarge(weight: KabanFontWeight = .bold) -> KabanFont {
        KabanFont(size: 32, relativeTo: .title, weight: weight, lineSpacing: 4)
    }

    /// Regular title style.
    public static func titleRegular(weight: KabanFontWeight = .bold) -> KabanFont {
        KabanFont(size: 26, relativeTo: .title2, weight: weight, lineSpacing: 3)
    }

    /// Small title style.
    public static func titleSmall(weight: KabanFontWeight = .bold) -> KabanFont {
        KabanFont(size: 20, relativeTo: .title3, weight: weight, lineSpacing: 3)
    }

    /// Large body style.
    public static func bodyLarge(weight: KabanFontWeight = .regular) -> KabanFont {
        KabanFont(size: 17, relativeTo: .body, weight: weight, lineSpacing: 3)
    }

    /// Regular body style.
    public static func bodyRegular(weight: KabanFontWeight = .regular) -> KabanFont {
        KabanFont(size: 15, relativeTo: .subheadline, weight: weight, lineSpacing: 3)
    }

    /// Small body style.
    public static func bodySmall(weight: KabanFontWeight = .regular) -> KabanFont {
        KabanFont(size: 13, relativeTo: .footnote, weight: weight, lineSpacing: 2)
    }

    /// Caption style.
    public static func captionRegular(weight: KabanFontWeight = .regular) -> KabanFont {
        KabanFont(size: 11, relativeTo: .caption2, weight: weight, lineSpacing: 2)
    }
}

extension View {
    /// Applies a Kaban font token and foreground color.
    public func kabanTextStyle(_ style: KabanFont, color: KabanColor) -> some View {
        modifier(KabanFontModifier(font: style))
            .lineSpacing(style.lineSpacing)
            .foregroundStyle(color.color)
    }
}

private struct KabanFontModifier: ViewModifier {
    private let weight: Font.Weight

    @ScaledMetric private var scaledSize: CGFloat

    init(font: KabanFont) {
        self.weight = font.weight
        _scaledSize = .init(wrappedValue: font.size, relativeTo: font.relativeTo)
    }

    func body(content: Content) -> some View {
        content.font(.system(size: scaledSize, weight: weight))
    }
}
