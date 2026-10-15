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
                HStack(spacing: 6) {
                    count(entry.metric.primaryValue, title: entry.metric.primaryLabel)
                    count(entry.metric.secondaryValue, title: entry.metric.secondaryLabel)
                }
                ProgressView(value: entry.metric.progress).tint(WidgetComicStyle.green)
                Text(String(localized: "album.open")).font(.caption2.weight(.bold))
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

    private func count(_ value: Int, title: String) -> some View {
        HStack(spacing: 3) {
            Text("\(value)").font(.caption.weight(.black))
            Text(title).font(.caption2.weight(.bold))
        }
        .lineLimit(1).minimumScaleFactor(0.7)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(WidgetComicStyle.panel, in: RoundedRectangle(cornerRadius: 4))
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(WidgetComicStyle.ink, lineWidth: 1.5))
    }
}
