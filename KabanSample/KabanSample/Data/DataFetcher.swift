import Foundation

nonisolated enum DataFetcherError: LocalizedError {
    case fruitNotFound(fruitID: String)
    case recipeNotFound(recipeID: String)

    var errorDescription: String? {
        switch self {
        case .fruitNotFound(let fruitID): "フルーツが見つかりませんでした (id: \(fruitID))"
        case .recipeNotFound(let recipeID): "レシピが見つかりませんでした (id: \(recipeID))"
        }
    }
}

actor DataFetcher {
    private let fruits: [Fruit] = [
        .apple, .banana, .orange, .grape, .strawberry, .peach, .cherry,
        .watermelon, .melon, .pineapple, .kiwi, .lemon, .greenApple,
        .pear, .mango, .blueberry, .olive, .lime,
    ]

    private let recipes: [Recipe] = [
        .fruitTart, .smoothie, .fruitPunch, .berryParfait,
        .citrusSalad, .fruitSandwich, .fruitCompote, .melonParfait,
    ]

    func fetchFruits() async throws -> [Fruit] {
        try await waitForFakeLatency()
        return fruits
    }

    func fetchFruits(color: FruitColor) async throws -> [Fruit] {
        try await waitForFakeLatency()
        return fruits.filter { $0.color == color }
    }

    func fetchFruit(fruitID: String) async throws -> Fruit {
        try await waitForFakeLatency()
        guard let fruit = fruits.first(where: { $0.id == fruitID }) else {
            throw DataFetcherError.fruitNotFound(fruitID: fruitID)
        }
        return fruit
    }

    func fetchRecipes() async throws -> [Recipe] {
        try await waitForFakeLatency()
        return recipes
    }

    func fetchRecipe(recipeID: String) async throws -> Recipe {
        try await waitForFakeLatency()
        guard let recipe = recipes.first(where: { $0.id == recipeID }) else {
            throw DataFetcherError.recipeNotFound(recipeID: recipeID)
        }
        return recipe
    }

    private func waitForFakeLatency() async throws {
        try await Task.sleep(for: .milliseconds(300))
    }
}
