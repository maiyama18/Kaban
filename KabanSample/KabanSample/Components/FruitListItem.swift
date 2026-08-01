import Kaban
import SwiftUI

struct FruitListItem: View {
    let fruit: Fruit
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 12) {
                Text(fruit.emoji)
                    .kabanTextStyle(.titleRegular(), color: .textPrimary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(fruit.name)
                        .kabanTextStyle(.bodyLarge(weight: .semibold), color: .textPrimary)

                    Text(fruit.color.displayName)
                        .kabanTextStyle(.bodySmall(), color: fruit.color.kabanColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .kabanForegroundStyle(.textSecondary)
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    List {
        FruitListItem(fruit: .apple) {}
        FruitListItem(fruit: .melon) {}
    }
}
