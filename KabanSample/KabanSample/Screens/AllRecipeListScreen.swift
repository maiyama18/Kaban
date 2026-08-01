import Kaban
import SwiftUI

struct AllRecipeListScreen: View {
    @Environment(AppNavigationFlow.self) private var navigationFlow

    @State private var recipesState: LoadingState<[Recipe]> = .empty

    private let dataFetcher = DataFetcher()

    var body: some View {
        LoadingStateView(state: recipesState) { recipes in
            List(recipes) { recipe in
                ActionRow(title: recipe.name) {
                    navigationFlow.push(.recipeDetail(recipeID: recipe.id))
                }
            }
        } retryAction: {
            await loadRecipes()
        }
        .navigationTitle("レシピ一覧")
        .task {
            await loadRecipes()
        }
    }

    private func loadRecipes() async {
        recipesState = .loading
        do {
            recipesState = .loaded(try await dataFetcher.fetchRecipes())
        } catch {
            recipesState = .failed(error)
        }
    }
}
