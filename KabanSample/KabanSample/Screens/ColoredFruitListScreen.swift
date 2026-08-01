import Kaban
import SwiftUI

struct ColoredFruitListScreen: View {
    let color: FruitColor

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
        .navigationTitle("\(color.displayName)色のフルーツ")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    navigationFlow.dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        .task {
            await loadFruits()
        }
    }

    private func loadFruits() async {
        fruitsState = .loading
        do {
            fruitsState = .loaded(try await dataFetcher.fetchFruits(color: color))
        } catch {
            fruitsState = .failed(error)
        }
    }
}
