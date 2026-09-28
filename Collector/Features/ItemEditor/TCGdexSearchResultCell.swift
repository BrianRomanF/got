import SwiftUI

struct TCGdexSearchResultCell: View {
    let result: TCGdexCardSearchResult

    var body: some View {
        HStack(spacing: 14) {
            AsyncImage(url: result.imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure, .empty:
                    Rectangle()
                        .fill(ComicTheme.blue)
                        .overlay {
                            Image(systemName: "rectangle.stack.fill")
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
                Text(result.name)
                    .font(.headline.weight(.black))
                    .foregroundStyle(ComicTheme.ink)
                    .lineLimit(2)

                Text(result.displaySubtitle)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(ComicTheme.ink.opacity(0.72))
                    .lineLimit(2)

                Text("TCGdex")
                    .font(.caption2.weight(.black))
                    .foregroundStyle(ComicTheme.red)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .comicPanel(fill: ComicTheme.panel)
    }
}
