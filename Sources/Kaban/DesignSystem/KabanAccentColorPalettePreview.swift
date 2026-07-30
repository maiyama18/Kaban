import SwiftUI

private struct KabanAccentColorPalettePreview: View {
    private let colors: [(name: String, token: KabanColor)] = [
        ("Red", .accentRed),
        ("Orange", .accentOrange),
        ("Yellow", .accentYellow),
        ("Lime", .accentLime),
        ("Green", .accentGreen),
        ("Mint", .accentMint),
        ("Teal", .accentTeal),
        ("Cyan", .accentCyan),
        ("Blue", .accentBlue),
        ("Indigo", .accentIndigo),
        ("Purple", .accentPurple),
        ("Pink", .accentPink),
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [.init(.adaptive(minimum: 120))], spacing: 16) {
                ForEach(colors.indices, id: \.self) { index in
                    let color = colors[index]

                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(color.token.color)
                            .frame(height: 72)

                        Text(color.name)
                            .kabanTextStyle(.bodyRegular(weight: .semibold), color: .textPrimary)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview("Accent Palette: Light") {
    KabanAccentColorPalettePreview()
        .preferredColorScheme(.light)
}

#Preview("Accent Palette: Dark") {
    KabanAccentColorPalettePreview()
        .preferredColorScheme(.dark)
}
