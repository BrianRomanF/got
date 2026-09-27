import SwiftUI

struct ItemReadingInput: View {
    @Binding var selection: ReadingStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.ReadingStatus.title.uppercased())
                .font(.caption.weight(.black))
                .foregroundStyle(ComicTheme.ink.opacity(0.75))

            ComicSegmentedControl(
                options: ReadingStatus.allCases,
                selection: $selection,
                title: { $0.title }
            )
        }
        .padding(16)
        .comicPanel(fill: .white)
    }
}
