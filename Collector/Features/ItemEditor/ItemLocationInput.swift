import SwiftUI

struct ItemLocationInput: View {
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.headline.weight(.black))
                    .foregroundStyle(ComicTheme.red)

                Text(L10n.ItemLocation.title.uppercased().vintageSafe)
                    .font(.caption.weight(.black))
                    .foregroundStyle(ComicTheme.ink.opacity(0.75))
            }

            TextField(
                "",
                text: $text,
                prompt: Text(L10n.ItemLocation.placeholder).foregroundStyle(ComicTheme.ink.opacity(0.55))
            )
            .textInputAutocapitalization(.words)
            .comicTextField()

            Text(L10n.ItemLocation.hint)
                .font(.caption.weight(.bold))
                .foregroundStyle(ComicTheme.ink.opacity(0.62))
        }
        .padding(16)
        .comicPanel(fill: .white)
    }
}
