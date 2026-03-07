import SwiftUI

private struct KabanAccentColorKey: EnvironmentKey {
    static let defaultValue: Color = KabanColor.accentOrange.color
}

public extension EnvironmentValues {
    var kabanAccentColor: Color {
        get { self[KabanAccentColorKey.self] }
        set { self[KabanAccentColorKey.self] = newValue }
    }
}
