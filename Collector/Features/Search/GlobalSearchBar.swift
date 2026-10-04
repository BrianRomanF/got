import SwiftUI

struct GlobalSearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.title3.weight(.black))
                .foregroundStyle(ComicTheme.red)

            TextField(
                "",
                text: $text,
                prompt: Text(L10n.GlobalSearch.placeholder).foregroundStyle(ComicTheme.ink.opacity(0.52))
            )
            .font(.headline.weight(.black))
            .foregroundStyle(ComicTheme.ink)
            .textInputAutocapitalization(.words)
            .disableAutocorrection(true)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.headline.weight(.black))
                        .foregroundStyle(ComicTheme.ink.opacity(0.6))
                }
                .accessibilityLabel(L10n.GlobalSearch.clear)
            }
        }
        .padding(16)
        .comicPanel(fill: .white)
    }
}
