import SwiftUI

private struct KabanAccentColorKey: EnvironmentKey {
    static let defaultValue: Color = KabanColor.accentOrange.color
}

extension EnvironmentValues {
    public var kabanAccentColor: Color {
        get { self[KabanAccentColorKey.self] }
        set { self[KabanAccentColorKey.self] = newValue }
    }
}
