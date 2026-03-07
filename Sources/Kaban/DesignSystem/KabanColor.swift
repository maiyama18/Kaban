import SwiftUI

public struct KabanColor: Sendable {
    internal let color: Color

    internal init(resource: ColorResource) {
        self.color = Color(resource)
    }

    public static let textPrimary = KabanColor(resource: .Text.primary)
    public static let textSecondary = KabanColor(resource: .Text.secondary)
    public static let textInvertedPrimary = KabanColor(resource: .Text.invertedPrimary)
    public static let textDanger = KabanColor(resource: .Text.danger)
    public static let textDisabled = KabanColor(resource: .Text.disabled)

    public static let surfaceDisabled = KabanColor(resource: .Surface.disabled)
    public static let surfaceDanger = KabanColor(resource: .Surface.danger)

    public static let accentPink = KabanColor(resource: .Accent.pink)
    public static let accentOrange = KabanColor(resource: .Accent.orange)
    public static let accentYellow = KabanColor(resource: .Accent.yellow)
    public static let accentGreen = KabanColor(resource: .Accent.green)
    public static let accentTeal = KabanColor(resource: .Accent.teal)
    public static let accentBlue = KabanColor(resource: .Accent.blue)
    public static let accentPurple = KabanColor(resource: .Accent.purple)
}
