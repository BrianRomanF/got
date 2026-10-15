import SwiftUI
import WidgetKit

struct ComicFollowingWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: CollectorWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(String(localized: "following.title"), systemImage: "bookmark.fill")
                .font(.caption.weight(.black))
                .foregroundStyle(WidgetComicStyle.red)
            if let series = entry.followedComic {
                HStack(spacing: 10) {
                    WidgetCoverThumbnailView(data: series.coverData, width: family == .systemSmall ? 36 : 44, height: 48)
                    Text(series.title).font(.subheadline.weight(.black)).lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                HStack(spacing: 6) {
                    count(series.ownedCount, title: String(localized: "following.owned"))
                    count(series.missingCount, title: String(localized: "following.missing"))
                }
                ProgressView(value: series.progress).tint(WidgetComicStyle.green)
                Text(String(localized: "following.open"))
                    .font(.caption2.weight(.bold))
            } else {
                Text(String(localized: "following.empty")).font(.subheadline.weight(.black))
                Text(String(localized: "following.choose")).font(.caption2.weight(.semibold)).lineLimit(3)
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(WidgetComicStyle.ink)
        .environment(\.colorScheme, .light)
        .widgetURL(entry.followedComic?.url ?? URL(string: "gotit://comics"))
        .containerBackground(for: .widget) { WidgetComicBackground() }
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
