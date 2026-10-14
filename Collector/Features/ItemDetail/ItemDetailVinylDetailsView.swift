import SwiftUI

struct ItemDetailVinylDetailsView: View {
    let item: CollectibleItem

    var body: some View {
        let rows = detailRows

        if !rows.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.VinylDetails.title.uppercased().vintageSafe)
                    .font(.caption.weight(.black))
                    .foregroundStyle(ComicTheme.ink.opacity(0.75))

                ForEach(rows, id: \.title) { row in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(row.title.uppercased().vintageSafe)
                            .font(.caption.weight(.black))
                            .foregroundStyle(ComicTheme.red)

                        Text(row.value)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(ComicTheme.ink.opacity(0.82))

                        Spacer(minLength: 0)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .comicPanel(fill: ComicTheme.panel)
        }
    }

    private var detailRows: [(title: String, value: String)] {
        var rows: [(String, String)] = []

        if let mediaCondition = item.vinylMediaCondition, mediaCondition.isKnown {
            rows.append((L10n.VinylDetails.mediaCondition, mediaCondition.title))
        }

        if let sleeveCondition = item.vinylSleeveCondition, sleeveCondition.isKnown {
            rows.append((L10n.VinylDetails.sleeveCondition, sleeveCondition.title))
        }

        if let catalogNumber = item.vinylCatalogNumber?.trimmingCharacters(in: .whitespacesAndNewlines), !catalogNumber.isEmpty {
            rows.append((L10n.VinylDetails.catalogNumber, catalogNumber))
        }

        return rows
    }
}
