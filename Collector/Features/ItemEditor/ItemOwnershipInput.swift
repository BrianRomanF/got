import SwiftUI

struct ItemOwnershipInput: View {
    @Binding var selection: ItemOwnershipStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.OwnershipFilter.title.uppercased())
                .font(.caption.weight(.black))
                .foregroundStyle(ComicTheme.ink.opacity(0.75))

            ComicSegmentedControl(
                options: ItemOwnershipStatus.allCases,
                selection: $selection,
                title: { $0.title }
            )
        }
        .padding(16)
        .comicPanel(fill: .white)
    }
}
