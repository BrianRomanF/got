import SwiftUI

struct DiscogsSearchResultCell: View {
    let result: DiscogsSearchResult

    var body: some View {
        HStack(spacing: 14) {
            AsyncImage(url: result.coverURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure, .empty:
                    Rectangle()
                        .fill(ComicTheme.red)
                        .overlay {
                            Image(systemName: result.format == .vinyl ? "record.circle.fill" : "music.note.list")
                                .font(.title.weight(.black))
                                .foregroundStyle(ComicTheme.panel)
                        }
                @unknown default:
                    Rectangle()
                        .fill(ComicTheme.red)
                }
            }
            .frame(width: 74, height: 74)
            .clipped()
            .overlay(
                Rectangle()
                    .stroke(ComicTheme.ink, lineWidth: 3)
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(result.title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(ComicTheme.ink)
                    .lineLimit(2)

                Text(result.displaySubtitle)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(ComicTheme.ink.opacity(0.72))
                    .lineLimit(2)

                Text("Discogs - \(result.format.title)")
                    .font(.caption2.weight(.black))
                    .foregroundStyle(ComicTheme.red)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .comicPanel(fill: ComicTheme.panel)
    }
}
