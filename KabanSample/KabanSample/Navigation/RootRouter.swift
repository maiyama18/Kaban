import Kaban
import Observation

@Observable
@MainActor
final class RootRouter {
    var selectedTab: SelectableTab = .fruit

    let fruitTabFlow = AppNavigationFlow()
    let recipeTabFlow = AppNavigationFlow()

    func showFruitDetail(fruitID: String) {
        prepareForCrossTabNavigation(to: .fruit)

        Task {
            await waitForPresentationAnimation()
            fruitTabFlow.push(.fruitDetail(fruitID: fruitID))
        }
    }

    func showRecipeDetail(recipeID: String) {
        prepareForCrossTabNavigation(to: .recipe)

        Task {
            await waitForPresentationAnimation()
            recipeTabFlow.push(.recipeDetail(recipeID: recipeID))
        }
    }

    func showColoredFruitDetail(color: FruitColor, fruitID: String) {
        prepareForCrossTabNavigation(to: .fruit)

        Task {
            await waitForPresentationAnimation()
            fruitTabFlow.presentSheet(.coloredFruitList(color: color))
            await waitForPresentationAnimation()
            fruitTabFlow.visibleNavigationFlow.push(.fruitDetail(fruitID: fruitID))
        }
    }

    private func prepareForCrossTabNavigation(to tab: SelectableTab) {
        fruitTabFlow.dismissPresentedContent()
        recipeTabFlow.dismissPresentedContent()

        selectedTab = tab

        flow(for: tab).popAll()
    }

    private func flow(for tab: SelectableTab) -> AppNavigationFlow {
        switch tab {
        case .fruit: fruitTabFlow
        case .recipe: recipeTabFlow
        }
    }

    /// 直前の dismiss / present のアニメーションが終わる前に次の遷移を行うと無視されるため、完了を待つ
    private func waitForPresentationAnimation() async {
        try? await Task.sleep(for: .milliseconds(500))
    }
}
