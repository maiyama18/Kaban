nonisolated enum PresentableSheet: Identifiable, Sendable {
    case coloredFruitList(color: FruitColor)

    var id: String {
        switch self {
        case .coloredFruitList(let color): "coloredFruitList-\(color.rawValue)"
        }
    }
}
