import SwiftUI
import WidgetKit

struct VinylAlbumWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: CollectorWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(header, systemImage: entry.featuredAlbum?.isFavorite == true ? "star.fill" : "opticaldisc")
                .font(.caption.weight(.black))
                .foregroundStyle(WidgetComicStyle.red)
                .lineLimit(1).minimumScaleFactor(0.8)

            if let album = entry.featuredAlbum {
                HStack(spacing: 10) {
                    WidgetCoverThumbnailView(data: album.coverData,
                        width: family == .systemSmall ? 46 : 56,
                        height: family == .systemSmall ? 46 : 56,
                        fallbackSymbolName: "opticaldisc")
                    VStack(alignment: .leading, spacing: 4) {
                        Text(album.title).font(.subheadline.weight(.black)).lineLimit(2)
                        if !album.subtitle.isEmpty {
                            Text(album.subtitle).font(.caption2.weight(.semibold)).lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                if let track = entry.suggestedTrack {
                    VStack(alignment: .leading, spacing: 3) {
                        Label(String(localized: "album.randomTrack"), systemImage: "shuffle")
                            .font(.caption2.weight(.black))
                            .foregroundStyle(WidgetComicStyle.red)
                        Text(track.title).font(.caption.weight(.bold)).lineLimit(2)
                    }
                } else {
                    Text(String(localized: "album.noTracks"))
                        .font(.caption2.weight(.semibold)).lineLimit(2)
                }
            } else {
                Text(String(localized: "album.empty")).font(.subheadline.weight(.black))
                Text(String(localized: "album.choose")).font(.caption2.weight(.semibold)).lineLimit(3)
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(WidgetComicStyle.ink)
        .environment(\.colorScheme, .light)
        .widgetURL(entry.featuredAlbum?.url ?? URL(string: "gotit://vinyl"))
        .containerBackground(for: .widget) { WidgetComicBackground() }
    }

    private var header: String {
        entry.featuredAlbum?.isFavorite == true ? String(localized: "album.favorite") : String(localized: "album.listen")
    }

}
