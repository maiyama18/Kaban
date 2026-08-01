import Kaban
import SwiftUI

struct FruitProductionAreaListScreen: View {
    let fruitID: String

    @Environment(AppNavigationFlow.self) private var navigationFlow

    @State private var fruitState: LoadingState<Fruit> = .empty

    private let dataFetcher = DataFetcher()

    var body: some View {
        LoadingStateView(state: fruitState) { fruit in
            List {
                Section {
                    ForEach(fruit.productionAreas, id: \.id) { area in
                        Text(area.name)
                            .kabanTextStyle(.bodyRegular(), color: .textPrimary)
                    }
                }

                Section("pop 操作") {
                    ActionRow(title: "1つ前に戻る") {
                        navigationFlow.pop()
                    }

                    ActionRow(title: "一覧まで戻る") {
                        navigationFlow.popAll()
                    }
                }
            }
        } retryAction: {
            await loadFruit()
        }
        .navigationTitle(navigationTitle)
        .task {
            await loadFruit()
        }
    }

    private var navigationTitle: String {
        guard case .loaded(let fruit) = fruitState else { return "" }
        return "\(fruit.name)の産地"
    }

    private func loadFruit() async {
        fruitState = .loading
        do {
            fruitState = .loaded(try await dataFetcher.fetchFruit(fruitID: fruitID))
        } catch {
            fruitState = .failed(error)
        }
    }
}
