import Kaban

nonisolated enum FruitColor: String, Sendable, Hashable {
    case red
    case orange
    case yellow
    case green
    case purple

    var displayName: String {
        switch self {
        case .red: "赤"
        case .orange: "オレンジ"
        case .yellow: "黄"
        case .green: "緑"
        case .purple: "紫"
        }
    }

    var kabanColor: KabanColor {
        switch self {
        case .red: .accentRed
        case .orange: .accentOrange
        case .yellow: .accentYellow
        case .green: .accentGreen
        case .purple: .accentPurple
        }
    }
}
