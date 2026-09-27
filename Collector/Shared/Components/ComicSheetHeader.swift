import SwiftUI

struct ComicSheetHeader: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(ComicTheme.titleFont)
                .foregroundStyle(ComicTheme.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.75)

            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(ComicTheme.ink.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .comicPanel(fill: ComicTheme.panel)
    }
}
