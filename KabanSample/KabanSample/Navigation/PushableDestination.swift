nonisolated enum PushableDestination: Hashable, Sendable {
    case fruitDetail(fruitID: String)
    case fruitProductionAreaList(fruitID: String)
    case recipeDetail(recipeID: String)
}
