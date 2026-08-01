import SwiftUI

@MainActor
struct ScreensBuilder {
    @ViewBuilder
    func pushDestination(_ destination: PushableDestination) -> some View {
        switch destination {
        case .fruitDetail(let fruitID):
            FruitDetailScreen(fruitID: fruitID)
        case .fruitProductionAreaList(let fruitID):
            FruitProductionAreaListScreen(fruitID: fruitID)
        case .recipeDetail(let recipeID):
            RecipeDetailScreen(recipeID: recipeID)
        }
    }

    @ViewBuilder
    func sheet(_ sheet: PresentableSheet) -> some View {
        switch sheet {
        case .coloredFruitList(let color):
            ColoredFruitListScreen(color: color)
        }
    }

    @ViewBuilder
    func fullScreen(_ fullScreen: PresentableFullScreen) -> some View {
        switch fullScreen {
        case .coloredFruitList(let color):
            ColoredFruitListScreen(color: color)
        }
    }
}
