import SwiftUI

struct ComicEmptyStateView: View {
    let systemName: String
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemName)
                .font(.title.weight(.black))
                .foregroundStyle(ComicTheme.red)

            Text(title.uppercased())
                .font(.headline.weight(.black))
                .foregroundStyle(ComicTheme.ink)

            Text(message)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(ComicTheme.ink.opacity(0.76))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .comicPanel(fill: ComicTheme.panel)
    }
}
