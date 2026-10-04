import SwiftUI

struct ItemDetailBookDetailsView: View {
    let item: CollectibleItem

    var body: some View {
        if shouldShowDetails {
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.BookDetails.title.uppercased().vintageSafe)
                    .font(.caption.weight(.black))
                    .foregroundStyle(ComicTheme.ink.opacity(0.75))

                if let rating = item.bookRating, rating > 0 {
                    HStack(spacing: 6) {
                        ForEach(1...5, id: \.self) { value in
                            Image(systemName: value <= rating ? "star.fill" : "star")
                                .font(.headline.weight(.black))
                                .foregroundStyle(value <= rating ? ComicTheme.yellow : ComicTheme.ink.opacity(0.35))
                        }
                    }
                }

                detailRow(title: L10n.BookDetails.protagonist, value: item.bookProtagonist)
                detailRow(title: L10n.BookDetails.series, value: item.bookSeries)
                detailRow(title: L10n.BookDetails.edition, value: item.bookEdition)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .comicPanel(fill: ComicTheme.panel)
        }
    }

    private var shouldShowDetails: Bool {
        item.bookRating != nil
            || hasValue(item.bookProtagonist)
            || hasValue(item.bookSeries)
            || hasValue(item.bookEdition)
    }

    @ViewBuilder
    private func detailRow(title: String, value: String?) -> some View {
        if hasValue(value), let value {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(title.uppercased().vintageSafe)
                    .font(.caption.weight(.black))
                    .foregroundStyle(ComicTheme.red)

                Text(value)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(ComicTheme.ink.opacity(0.82))

                Spacer(minLength: 0)
            }
        }
    }

    private func hasValue(_ value: String?) -> Bool {
        !(value?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }
}
