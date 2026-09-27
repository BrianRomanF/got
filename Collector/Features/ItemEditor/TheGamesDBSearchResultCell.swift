import SwiftUI

struct TheGamesDBSearchResultCell: View {
    let result: TheGamesDBGameSearchResult

    var body: some View {
        HStack(spacing: 14) {
            AsyncImage(url: result.boxartURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure, .empty:
                    Rectangle()
                        .fill(ComicTheme.blue)
                        .overlay {
                            Image(systemName: "gamecontroller.fill")
                                .font(.title.weight(.black))
                                .foregroundStyle(ComicTheme.panel)
                        }
                @unknown default:
                    Rectangle()
                        .fill(ComicTheme.blue)
                }
            }
            .frame(width: 74, height: 104)
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

                Text("TheGamesDB")
                    .font(.caption2.weight(.black))
                    .foregroundStyle(ComicTheme.red)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .comicPanel(fill: ComicTheme.panel)
    }
}
