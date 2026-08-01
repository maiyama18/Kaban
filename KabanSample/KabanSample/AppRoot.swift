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
    }
}
