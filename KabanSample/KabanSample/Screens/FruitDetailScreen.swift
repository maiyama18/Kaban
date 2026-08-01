import Kaban
import SwiftUI

struct FruitDetailScreen: View {
    let fruitID: String

    @Environment(AppNavigationFlow.self) private var navigationFlow

    @State private var fruitState: LoadingState<Fruit> = .empty

    private let dataFetcher = DataFetcher()

    var body: some View {
        LoadingStateView(state: fruitState) { fruit in
            List {
                Section {
                    Text(fruit.emoji)
                        .font(.system(size: 100))
                        .frame(maxWidth: .infinity)
                }

                Section("概要") {
                    Text(fruit.overview)
                        .kabanTextStyle(.bodyRegular(), color: .textPrimary)
                }

                Section("push 遷移") {
                    NavigationLink(value: PushableDestination.fruitProductionAreaList(fruitID: fruit.id)) {
                        Text("産地一覧")
                            .kabanTextStyle(.bodyRegular(), color: .textPrimary)
                    }
                }

                Section("presentation") {
                    ActionRow(title: "同じ色のフルーツ (sheet)") {
                        navigationFlow.presentSheet(.coloredFruitList(color: fruit.color))
                    }

                    ActionRow(title: "同じ色のフルーツ (fullScreen)") {
                        navigationFlow.presentFullScreen(.coloredFruitList(color: fruit.color))
                    }

                    ActionRow(title: "概要をアラートで表示") {
                        navigationFlow.presentAlert(
                            PresentableAlert(title: fruit.name, message: fruit.overview) {
                                Button("OK") {}
                            }
                        )
                    }
                }
            }
        } retryAction: {
            await loadFruit()
        }
        .navigationTitle(fruitName ?? "")
        .task {
            await loadFruit()
        }
    }

    private var fruitName: String? {
        guard case .loaded(let fruit) = fruitState else { return nil }
        return fruit.name
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
