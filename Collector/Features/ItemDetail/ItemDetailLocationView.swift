import SwiftUI

struct ItemDetailLocationView: View {
    let location: String?

    var body: some View {
        if let location, !location.isEmpty {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.title3.weight(.black))
                    .foregroundStyle(ComicTheme.red)

                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.ItemLocation.title.uppercased().vintageSafe)
                        .font(.caption.weight(.black))
                        .foregroundStyle(ComicTheme.ink.opacity(0.7))

                    Text(location)
                        .font(.body.weight(.bold))
                        .foregroundStyle(ComicTheme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(16)
            .comicPanel(fill: .white)
        }
    }
}
