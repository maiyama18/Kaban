nonisolated struct Fruit: Sendable, Hashable, Identifiable {
    let id: String
    let name: String
    let emoji: String
    let color: FruitColor
    let overview: String
    let productionAreas: [FruitProductionArea]
}

nonisolated extension Fruit {
    static let apple = Fruit(
        id: "apple",
        name: "りんご",
        emoji: "🍎",
        color: .red,
        overview: "甘酸っぱくてシャキシャキした食感が特徴の果物。世界中で栽培されており、品種は数千種類にも及ぶ。",
        productionAreas: [
            FruitProductionArea(id: "aomori", name: "青森県"),
            FruitProductionArea(id: "nagano", name: "長野県"),
            FruitProductionArea(id: "iwate", name: "岩手県"),
        ]
    )
    static let banana = Fruit(
        id: "banana",
        name: "バナナ",
        emoji: "🍌",
        color: .yellow,
        overview: "栄養豊富でエネルギー補給に最適な果物。熱帯地域で栽培され、年間を通じて手に入りやすい。",
        productionAreas: [
            FruitProductionArea(id: "okinawa", name: "沖縄県"),
            FruitProductionArea(id: "kagoshima", name: "鹿児島県"),
        ]
    )
    static let orange = Fruit(
        id: "orange",
        name: "オレンジ",
        emoji: "🍊",
        color: .orange,
        overview: "ビタミンCが豊富でジューシーな柑橘類。爽やかな香りと甘酸っぱさが特徴で、世界中で愛されている。",
        productionAreas: [
            FruitProductionArea(id: "ehime", name: "愛媛県"),
            FruitProductionArea(id: "wakayama", name: "和歌山県"),
            FruitProductionArea(id: "shizuoka", name: "静岡県"),
        ]
    )
    static let grape = Fruit(
        id: "grape",
        name: "ぶどう",
        emoji: "🍇",
        color: .purple,
        overview: "甘くて多汁な粒が房状になった果物。生食用とワイン用で品種が異なり、色も緑・赤・紫と多彩。",
        productionAreas: [
            FruitProductionArea(id: "yamanashi", name: "山梨県"),
            FruitProductionArea(id: "nagano", name: "長野県"),
            FruitProductionArea(id: "okayama", name: "岡山県"),
        ]
    )
    static let strawberry = Fruit(
        id: "strawberry",
        name: "いちご",
        emoji: "🍓",
        color: .red,
        overview: "甘酸っぱくて香り高い人気の果物。ビタミンCが豊富で、ケーキやジャムなどスイーツとの相性が抜群。",
        productionAreas: [
            FruitProductionArea(id: "tochigi", name: "栃木県"),
            FruitProductionArea(id: "fukuoka", name: "福岡県"),
            FruitProductionArea(id: "kumamoto", name: "熊本県"),
        ]
    )
    static let peach = Fruit(
        id: "peach",
        name: "もも",
        emoji: "🍑",
        color: .orange,
        overview: "柔らかくてジューシーな夏の果物。甘い香りととろけるような果肉が特徴。",
        productionAreas: [
            FruitProductionArea(id: "yamanashi", name: "山梨県"),
            FruitProductionArea(id: "fukushima", name: "福島県"),
            FruitProductionArea(id: "nagano", name: "長野県"),
        ]
    )
    static let cherry = Fruit(
        id: "cherry",
        name: "さくらんぼ",
        emoji: "🍒",
        color: .red,
        overview: "小さくて可愛らしい見た目の果物。甘みと酸味のバランスが良く、初夏の味覚として人気。",
        productionAreas: [
            FruitProductionArea(id: "yamagata", name: "山形県"),
            FruitProductionArea(id: "hokkaido", name: "北海道"),
            FruitProductionArea(id: "yamanashi", name: "山梨県"),
        ]
    )
    static let watermelon = Fruit(
        id: "watermelon",
        name: "すいか",
        emoji: "🍉",
        color: .green,
        overview: "夏を代表する大きな果物。約90%が水分で、暑い日の水分補給に最適。",
        productionAreas: [
            FruitProductionArea(id: "kumamoto", name: "熊本県"),
            FruitProductionArea(id: "chiba", name: "千葉県"),
            FruitProductionArea(id: "yamagata", name: "山形県"),
        ]
    )
    static let melon = Fruit(
        id: "melon",
        name: "メロン",
        emoji: "🍈",
        color: .green,
        overview: "高級果物として知られる甘い果物。芳醇な香りととろけるような甘さが魅力。",
        productionAreas: [
            FruitProductionArea(id: "ibaraki", name: "茨城県"),
            FruitProductionArea(id: "hokkaido", name: "北海道"),
            FruitProductionArea(id: "kumamoto", name: "熊本県"),
        ]
    )
    static let pineapple = Fruit(
        id: "pineapple",
        name: "パイナップル",
        emoji: "🍍",
        color: .yellow,
        overview: "トロピカルな風味が特徴の南国の果物。甘みと酸味のバランスが良く、ビタミンB1も豊富。",
        productionAreas: [
            FruitProductionArea(id: "okinawa", name: "沖縄県"),
            FruitProductionArea(id: "kagoshima", name: "鹿児島県"),
        ]
    )
    static let kiwi = Fruit(
        id: "kiwi",
        name: "キウイ",
        emoji: "🥝",
        color: .green,
        overview: "鮮やかな緑色の果肉が特徴の果物。ビタミンCと食物繊維が非常に豊富。",
        productionAreas: [
            FruitProductionArea(id: "ehime", name: "愛媛県"),
            FruitProductionArea(id: "fukuoka", name: "福岡県"),
            FruitProductionArea(id: "wakayama", name: "和歌山県"),
        ]
    )
    static let lemon = Fruit(
        id: "lemon",
        name: "レモン",
        emoji: "🍋",
        color: .yellow,
        overview: "強い酸味が特徴の柑橘類。ビタミンCの含有量が高く、料理や飲み物に幅広く使われる。",
        productionAreas: [
            FruitProductionArea(id: "hiroshima", name: "広島県"),
            FruitProductionArea(id: "ehime", name: "愛媛県"),
            FruitProductionArea(id: "wakayama", name: "和歌山県"),
        ]
    )
    static let greenApple = Fruit(
        id: "green_apple",
        name: "青りんご",
        emoji: "🍏",
        color: .green,
        overview: "爽やかな酸味とさっぱりした甘さが特徴の果物。サラダやスムージーにもよく使われる。",
        productionAreas: [
            FruitProductionArea(id: "nagano", name: "長野県"),
            FruitProductionArea(id: "aomori", name: "青森県"),
            FruitProductionArea(id: "iwate", name: "岩手県"),
        ]
    )
    static let pear = Fruit(
        id: "pear",
        name: "洋梨",
        emoji: "🍐",
        color: .green,
        overview: "なめらかでとろけるような食感が特徴の果物。追熟させることで甘みと香りが増す。",
        productionAreas: [
            FruitProductionArea(id: "yamagata", name: "山形県"),
            FruitProductionArea(id: "niigata", name: "新潟県"),
            FruitProductionArea(id: "nagano", name: "長野県"),
        ]
    )
    static let mango = Fruit(
        id: "mango",
        name: "マンゴー",
        emoji: "🥭",
        color: .orange,
        overview: "濃厚な甘みと芳醇な香りが特徴のトロピカルフルーツ。世界三大果物の一つとされる。",
        productionAreas: [
            FruitProductionArea(id: "miyazaki", name: "宮崎県"),
            FruitProductionArea(id: "okinawa", name: "沖縄県"),
            FruitProductionArea(id: "kagoshima", name: "鹿児島県"),
        ]
    )
    static let blueberry = Fruit(
        id: "blueberry",
        name: "ブルーベリー",
        emoji: "🫐",
        color: .purple,
        overview: "小さくて濃い青紫色の果物。アントシアニンが豊富で目の健康に良いとされる。",
        productionAreas: [
            FruitProductionArea(id: "nagano", name: "長野県"),
            FruitProductionArea(id: "ibaraki", name: "茨城県"),
            FruitProductionArea(id: "gunma", name: "群馬県"),
        ]
    )
    static let olive = Fruit(
        id: "olive",
        name: "オリーブ",
        emoji: "🫒",
        color: .green,
        overview: "地中海沿岸原産の小さな果物。オリーブオイルの原料として世界中で栽培されている。",
        productionAreas: [
            FruitProductionArea(id: "kagawa", name: "香川県"),
            FruitProductionArea(id: "hiroshima", name: "広島県"),
        ]
    )
    static let lime = Fruit(
        id: "lime",
        name: "ライム",
        emoji: "🍋‍🟩",
        color: .green,
        overview: "レモンよりも小さく、独特の香りを持つ柑橘類。カクテルや料理の風味付けに欠かせない。",
        productionAreas: [
            FruitProductionArea(id: "okinawa", name: "沖縄県"),
            FruitProductionArea(id: "kagoshima", name: "鹿児島県"),
        ]
    )
}
