import Kaban
import SwiftUI

struct AppRoot: View {
    @State private var rootRouter = RootRouter()

    private let screensBuilder = ScreensBuilder()

    var body: some View {
        @Bindable var rootRouter = rootRouter

        TabView(selection: $rootRouter.selectedTab) {
            Tab("フルーツ", systemImage: "leaf", value: SelectableTab.fruit) {
                NavigationFlowContainer(
                    flow: rootRouter.fruitTabFlow,
                    pushDestination: screensBuilder.pushDestination,
                    sheet: screensBuilder.sheet,
                    fullScreen: screensBuilder.fullScreen,
                    root: {
                        AllFruitListScreen()
                    }
                )
            }

            Tab("レシピ", systemImage: "book", value: SelectableTab.recipe) {
                NavigationFlowContainer(
                    flow: rootRouter.recipeTabFlow,
                    pushDestination: screensBuilder.pushDestination,
                    sheet: screensBuilder.sheet,
                    fullScreen: screensBuilder.fullScreen,
                    root: {
                        AllRecipeListScreen()
                    }
                )
            }
        }
        .environment(rootRouter)
        .environment(\.kabanAccentColor, .accentGreen)
        .onOpenURL { url in
            handleDeepLink(url)
        }
    }

    /// kabansample://fruit/apple
    /// kabansample://recipe/fruit_tart
    /// kabansample://coloredFruit/red/strawberry
    private func handleDeepLink(_ url: URL) {
        let pathComponents = url.path().split(separator: "/").map(String.init)

        switch url.host() {
        case "fruit":
            guard let fruitID = pathComponents.first else { return }
            rootRouter.showFruitDetail(fruitID: fruitID)
        case "recipe":
            guard let recipeID = pathComponents.first else { return }
            rootRouter.showRecipeDetail(recipeID: recipeID)
        case "coloredFruit":
            guard pathComponents.count == 2, let color = FruitColor(rawValue: pathComponents[0]) else { return }
            rootRouter.showColoredFruitDetail(color: color, fruitID: pathComponents[1])
        default:
            break
        }
    }
}
