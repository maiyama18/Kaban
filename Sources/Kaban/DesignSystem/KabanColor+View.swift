import SwiftUI

extension View {
    /// Applies a Kaban color token as the foreground style.
    public func kabanForegroundStyle(_ color: KabanColor) -> some View {
        foregroundStyle(color.color)
    }

    /// Applies a Kaban color token as the tint color.
    public func kabanTint(_ color: KabanColor) -> some View {
        tint(color.color)
    }
}
