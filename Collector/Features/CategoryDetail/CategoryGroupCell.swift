import SwiftUI

struct CategoryGroupCell: View {
    let group: CollectionGroup
    let template: CollectionTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: shelfSymbol)
                .font(.title.weight(.black))
                .foregroundStyle(shelfColor)

            Text(group.title.uppercased())
                .font(.headline.weight(.black))
                .foregroundStyle(ComicTheme.ink)
                .lineLimit(2)

            if !group.subtitle.isEmpty {
                Text(group.subtitle)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(ComicTheme.ink.opacity(0.68))
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
        .padding(14)
        .comicPanel(fill: ComicTheme.yellow)
    }

    private var shelfSymbol: String {
        switch template {
        case .books:
            "books.vertical.fill"
        case .comics:
            "book.closed.fill"
        case .games:
            "gamecontroller.fill"
        case .vinyl:
            "record.circle.fill"
        case .tradingCards:
            "rectangle.stack.fill"
        case .collectibles:
            "star.square.fill"
        case .custom:
            "square.stack.3d.up.fill"
        }
    }

    private var shelfColor: Color {
        switch template {
        case .books:
            ComicTheme.red
        case .comics:
            ComicTheme.blue
        case .games:
            ComicTheme.green
        case .vinyl:
            ComicTheme.ink
        case .tradingCards:
            ComicTheme.red
        case .collectibles, .custom:
            ComicTheme.blue
        }
    }
}
