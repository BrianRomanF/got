import SwiftUI

struct ItemBookDetailsInput: View {
    @Binding var rating: Int
    @Binding var protagonist: String
    @Binding var series: String
    @Binding var edition: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(L10n.BookDetails.title.uppercased().vintageSafe)
                .font(.caption.weight(.black))
                .foregroundStyle(ComicTheme.ink.opacity(0.75))

            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.BookDetails.rating.uppercased().vintageSafe)
                    .font(.caption.weight(.black))
                    .foregroundStyle(ComicTheme.red)

                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { value in
                        Button {
                            rating = rating == value ? 0 : value
                        } label: {
                            Image(systemName: value <= rating ? "star.fill" : "star")
                                .font(.title3.weight(.black))
                                .foregroundStyle(value <= rating ? ComicTheme.yellow : ComicTheme.ink.opacity(0.45))
                                .frame(width: 40, height: 40)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 7)
                                        .stroke(ComicTheme.ink, lineWidth: 2)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            TextField("", text: $protagonist, prompt: Text(L10n.BookDetails.protagonistPlaceholder).foregroundStyle(ComicTheme.ink.opacity(0.55)))
                .comicTextField()

            TextField("", text: $series, prompt: Text(L10n.BookDetails.seriesPlaceholder).foregroundStyle(ComicTheme.ink.opacity(0.55)))
                .comicTextField()

            TextField("", text: $edition, prompt: Text(L10n.BookDetails.editionPlaceholder).foregroundStyle(ComicTheme.ink.opacity(0.55)))
                .comicTextField()
        }
        .padding(16)
        .comicPanel(fill: .white)
    }
}
