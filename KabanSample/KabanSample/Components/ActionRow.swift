import Kaban
import SwiftUI

struct ActionRow: View {
    let title: String
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            Text(title)
                .kabanTextStyle(.bodyRegular(), color: .textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    List {
        ActionRow(title: "アクション") {}
    }
}
