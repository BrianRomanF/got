import SwiftUI

struct HomeHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Home.eyebrow.uppercased())
                .font(.caption.weight(.black))
                .foregroundStyle(ComicTheme.red)

            Text(L10n.Home.title.uppercased())
                .font(ComicTheme.displayFont)
                .foregroundStyle(ComicTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 8)
    }
}
