import SwiftUI

struct GlobalSearchResultCell: View {
    let result: GlobalSearchResult

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: result.kind.symbolName)
                .font(.title2.weight(.black))
                .foregroundStyle(ComicTheme.ink)
                .frame(width: 44, height: 44)
                .background(ComicTheme.yellow)
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(ComicTheme.ink, lineWidth: 2)
                )

            VStack(alignment: .leading, spacing: 5) {
                Text(result.title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(ComicTheme.ink)
                    .lineLimit(2)

                if !result.subtitle.isEmpty {
                    Text(result.subtitle)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(ComicTheme.ink.opacity(0.68))
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.black))
                .foregroundStyle(ComicTheme.ink.opacity(0.55))
        }
        .padding(14)
        .comicPanel(fill: ComicTheme.panel)
    }
}
