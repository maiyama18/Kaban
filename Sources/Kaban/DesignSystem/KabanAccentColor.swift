import SwiftUI

private struct KabanAccentColorKey: EnvironmentKey {
    static let defaultValue: KabanColor = .accentOrange
}

extension EnvironmentValues {
    public var kabanAccentColor: KabanColor {
        get { self[KabanAccentColorKey.self] }
        set { self[KabanAccentColorKey.self] = newValue }
    }
}
