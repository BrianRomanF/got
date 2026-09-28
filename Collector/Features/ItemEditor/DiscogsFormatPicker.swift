import SwiftUI

struct DiscogsFormatPicker: View {
    @Binding var selection: DiscogsMediaFormat

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.Discogs.format.uppercased().vintageSafe)
                .font(.caption.weight(.black))
                .foregroundStyle(ComicTheme.ink.opacity(0.75))

            ComicSegmentedControl(
                options: DiscogsMediaFormat.allCases,
                selection: $selection,
                title: { $0.title }
            )
        }
        .padding(16)
        .comicPanel(fill: ComicTheme.panel)
    }
}
