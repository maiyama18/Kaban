import Kaban
import SwiftUI

struct AllFruitListScreen: View {
    @Environment(AppNavigationFlow.self) private var navigationFlow

    @State private var fruitsState: LoadingState<[Fruit]> = .empty

    private let dataFetcher = DataFetcher()

    var body: some View {
        LoadingStateView(state: fruitsState) { fruits in
            List(fruits) { fruit in
                FruitListItem(fruit: fruit) {
                    navigationFlow.push(.fruitDetail(fruitID: fruit.id))
                }
            }
        } retryAction: {
            await loadFruits()
        }
        .navigationTitle("フルーツ一覧")
        .task {
            await loadFruits()
        }
    }

    private func loadFruits() async {
        fruitsState = .loading
        do {
            fruitsState = .loaded(try await dataFetcher.fetchFruits())
        } catch {
            fruitsState = .failed(error)
        }
    }
}
