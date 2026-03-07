import SwiftUI

extension View {
    public func kabanForegroundStyle(_ color: KabanColor) -> some View {
        foregroundStyle(color.color)
    }

    public func kabanTint(_ color: KabanColor) -> some View {
        tint(color.color)
    }
}
