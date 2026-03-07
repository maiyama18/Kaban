import SwiftUI

public struct KabanColor: Sendable {
    public let color: Color

    internal init(resource: ColorResource) {
        self.color = Color(resource)
    }
}

public extension KabanColor {
    static let textPrimary = KabanColor(resource: .Text.primary)
    static let textSecondary = KabanColor(resource: .Text.secondary)
    static let textInvertedPrimary = KabanColor(resource: .Text.invertedPrimary)
    static let textDanger = KabanColor(resource: .Text.danger)
    static let textDisabled = KabanColor(resource: .Text.disabled)

    static let surfaceDisabled = KabanColor(resource: .Surface.disabled)
    static let surfaceDanger = KabanColor(resource: .Surface.danger)

    static let accentPink = KabanColor(resource: .Accent.pink)
    static let accentOrange = KabanColor(resource: .Accent.orange)
    static let accentYellow = KabanColor(resource: .Accent.yellow)
    static let accentGreen = KabanColor(resource: .Accent.green)
    static let accentTeal = KabanColor(resource: .Accent.teal)
    static let accentBlue = KabanColor(resource: .Accent.blue)
    static let accentPurple = KabanColor(resource: .Accent.purple)
}
