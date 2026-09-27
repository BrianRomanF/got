import SwiftUI

struct ComicVineSeriesSearchField: View {
    @Binding var text: String
    let onSearch: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            TextField("", text: $text, prompt: Text(L10n.ComicVine.seriesSearchPlaceholder).foregroundStyle(ComicTheme.ink.opacity(0.45)))
                .textInputAutocapitalization(.words)
                .submitLabel(.search)
                .onSubmit(onSearch)
                .comicTextField()

            Button(action: onSearch) {
                Image(systemName: "magnifyingglass")
                    .font(.headline.weight(.black))
                    .foregroundStyle(ComicTheme.ink)
                    .frame(width: 52, height: 52)
                    .background(ComicTheme.yellow)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(ComicTheme.ink, lineWidth: 3)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .shadow(color: ComicTheme.ink, radius: 0, x: 4, y: 4)
            }
            .accessibilityLabel(L10n.ComicVine.search)
        }
    }
}
