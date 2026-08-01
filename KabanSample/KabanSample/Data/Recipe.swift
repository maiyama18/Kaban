nonisolated struct Recipe: Sendable, Hashable, Identifiable {
    let id: String
    let name: String
    let overview: String
    let fruits: [Fruit]
}

nonisolated extension Recipe {
    static let fruitTart = Recipe(
        id: "fruit_tart",
        name: "フルーツタルト",
        overview: "サクサクのタルト生地にカスタードクリームを敷き、色とりどりのフルーツを美しく並べた定番スイーツ。",
        fruits: [.strawberry, .kiwi, .blueberry, .orange]
    )
    static let smoothie = Recipe(
        id: "smoothie",
        name: "トロピカルスムージー",
        overview: "南国フルーツをミックスした爽やかなスムージー。氷と一緒にミキサーにかけるだけで簡単に作れる。",
        fruits: [.banana, .mango, .pineapple]
    )
    static let fruitPunch = Recipe(
        id: "fruit_punch",
        name: "フルーツポンチ",
        overview: "カラフルなフルーツをサイダーに浮かべた、パーティーにぴったりのデザート。",
        fruits: [.apple, .orange, .grape, .peach]
    )
    static let berryParfait = Recipe(
        id: "berry_parfait",
        name: "ベリーパフェ",
        overview: "甘酸っぱいベリー類とクリームを層にした贅沢なパフェ。グラノーラを加えれば朝食にも最適。",
        fruits: [.strawberry, .blueberry]
    )
    static let citrusSalad = Recipe(
        id: "citrus_salad",
        name: "シトラスサラダ",
        overview: "柑橘類の爽やかな酸味を活かしたヘルシーなフルーツサラダ。前菜やデザートとして楽しめる。",
        fruits: [.orange, .kiwi, .lemon]
    )
    static let fruitSandwich = Recipe(
        id: "fruit_sandwich",
        name: "フルーツサンド",
        overview: "ふわふわの食パンに生クリームとフルーツを挟んだ人気のスイーツ。断面の美しさが特徴。",
        fruits: [.strawberry, .kiwi, .banana, .mango]
    )
    static let fruitCompote = Recipe(
        id: "fruit_compote",
        name: "フルーツコンポート",
        overview: "フルーツを白ワインとシロップでじっくり煮込んだ上品なデザート。保存もきくので作り置きにも便利。",
        fruits: [.peach, .cherry, .grape]
    )
    static let melonParfait = Recipe(
        id: "melon_parfait",
        name: "贅沢メロンパフェ",
        overview: "高級メロンをふんだんに使った特別なパフェ。記念日や特別な日のデザートにぴったり。",
        fruits: [.melon, .kiwi]
    )
}
