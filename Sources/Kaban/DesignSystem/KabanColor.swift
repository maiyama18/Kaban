import SwiftUI

/// Color token used by Kaban components.
public struct KabanColor: Sendable {
    internal let color: Color

    /// Creates a Kaban color token from a SwiftUI color.
    public init(_ color: Color) {
        self.color = color
    }

    internal init(resource: ColorResource) {
        self.color = Color(resource)
    }

    /// Primary text color.
    public static let textPrimary = KabanColor(resource: .Text.primary)
    /// Secondary text color.
    public static let textSecondary = KabanColor(resource: .Text.secondary)
    /// Primary text color used on filled backgrounds.
    public static let textInvertedPrimary = KabanColor(resource: .Text.invertedPrimary)
    /// Text color for destructive or error states.
    public static let textDanger = KabanColor(resource: .Text.danger)
    /// Text color for disabled controls.
    public static let textDisabled = KabanColor(resource: .Text.disabled)

    /// Neutral surface color.
    public static let surfaceNeutral = KabanColor(resource: .Surface.neutral)
    /// Disabled surface color.
    public static let surfaceDisabled = KabanColor(resource: .Surface.disabled)
    /// Destructive or error surface color.
    public static let surfaceDanger = KabanColor(resource: .Surface.danger)

    /// Pink accent color.
    public static let accentPink = KabanColor(resource: .Accent.pink)
    /// Orange accent color.
    public static let accentOrange = KabanColor(resource: .Accent.orange)
    /// Yellow accent color.
    public static let accentYellow = KabanColor(resource: .Accent.yellow)
    /// Green accent color.
    public static let accentGreen = KabanColor(resource: .Accent.green)
    /// Teal accent color.
    public static let accentTeal = KabanColor(resource: .Accent.teal)
    /// Blue accent color.
    public static let accentBlue = KabanColor(resource: .Accent.blue)
    /// Purple accent color.
    public static let accentPurple = KabanColor(resource: .Accent.purple)
}
