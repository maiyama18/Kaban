import Kaban
import SwiftUI

struct RecipeDetailScreen: View {
    let recipeID: String

    @Environment(RootRouter.self) private var rootRouter

    @State private var recipeState: LoadingState<Recipe> = .empty

    private let dataFetcher = DataFetcher()

    var body: some View {
        LoadingStateView(state: recipeState) { recipe in
            List {
                Section("概要") {
                    Text(recipe.overview)
                        .kabanTextStyle(.bodyRegular(), color: .textPrimary)
                }

                Section("使用するフルーツ") {
                    ForEach(recipe.fruits) { fruit in
                        FruitListItem(fruit: fruit) {
                            rootRouter.showFruitDetail(fruitID: fruit.id)
                        }
                    }
                }
            }
        } retryAction: {
            await loadRecipe()
        }
        .navigationTitle(recipeName ?? "")
        .task {
            await loadRecipe()
        }
    }

    private var recipeName: String? {
        guard case .loaded(let recipe) = recipeState else { return nil }
        return recipe.name
    }

    private func loadRecipe() async {
        recipeState = .loading
        do {
            recipeState = .loaded(try await dataFetcher.fetchRecipe(recipeID: recipeID))
        } catch {
            recipeState = .failed(error)
        }
    }
}
