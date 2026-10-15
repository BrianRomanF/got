import SwiftUI
import WidgetKit

private let appGroupIdentifier = "group.com.brianroman.Collectorappmen"
private let snapshotKey = "collector.widgetDashboardSnapshot"

struct CollectorWidgetEntry: TimelineEntry {
    let date: Date
    let metric: WidgetMetricSnapshot
    var readingBooks: [ReadingBookWidgetItem] = []
}

struct CollectorWidgetProvider: TimelineProvider {
    let kind: CollectorWidgetKind

    func placeholder(in context: Context) -> CollectorWidgetEntry {
        CollectorWidgetEntry(date: .now, metric: kind.placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (CollectorWidgetEntry) -> Void) {
        completion(CollectorWidgetEntry(date: .now, metric: metric(), readingBooks: readingBooks()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CollectorWidgetEntry>) -> Void) {
        let entry = CollectorWidgetEntry(date: .now, metric: metric(), readingBooks: readingBooks())
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now.addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func readingBooks() -> [ReadingBookWidgetItem] {
        #if LOCAL_DEVICE_BUILD
        return []
        #else
        guard let data = UserDefaults(suiteName: appGroupIdentifier)?.data(forKey: snapshotKey),
              let snapshot = try? JSONDecoder().decode(WidgetDashboardSnapshot.self, from: data) else { return [] }
        return snapshot.readingBooks ?? []
        #endif
    }

    private func metric() -> WidgetMetricSnapshot {
        #if LOCAL_DEVICE_BUILD
        return kind.placeholder
        #else
        guard
            let defaults = UserDefaults(suiteName: appGroupIdentifier),
            let data = defaults.data(forKey: snapshotKey),
            let snapshot = try? JSONDecoder().decode(WidgetDashboardSnapshot.self, from: data)
        else {
            return kind.placeholder
        }

        switch kind {
        case .books:
            return snapshot.books
        case .comics:
            return snapshot.comics
        case .games:
            return snapshot.games
        case .vinyl:
            return snapshot.vinyl
        }
        #endif
    }
}

struct CollectorWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: CollectorWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(entry.metric.title.uppercased())
                    .font(.caption.weight(.black))
                    .foregroundStyle(WidgetComicStyle.red)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Text("\(Int(entry.metric.progress * 100))%")
                    .font(.headline.weight(.black))
                    .foregroundStyle(WidgetComicStyle.ink)
                    .minimumScaleFactor(0.7)
            }

            progressBar

            HStack(spacing: 10) {
                stat(value: entry.metric.primaryValue, label: entry.metric.primaryLabel)
                stat(value: entry.metric.secondaryValue, label: entry.metric.secondaryLabel)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.metric.highlightTitle)
                    .font(family == .systemSmall ? .subheadline.weight(.black) : .headline.weight(.black))
                    .foregroundStyle(WidgetComicStyle.ink)
                    .lineLimit(family == .systemSmall ? 2 : 1)
                    .minimumScaleFactor(0.75)

                Text(entry.metric.highlightSubtitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(WidgetComicStyle.ink.opacity(0.8))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .environment(\.colorScheme, .light)
        .containerBackground(for: .widget) {
            WidgetComicBackground()
        }
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(WidgetComicStyle.panel)
                Capsule()
                    .fill(WidgetComicStyle.green)
                    .frame(width: entry.metric.progress > 0 ? min(proxy.size.width, max(8, proxy.size.width * entry.metric.progress)) : 0)
            }
        }
        .frame(height: 8)
        .overlay(Capsule().stroke(WidgetComicStyle.ink, lineWidth: 1.5))
    }

    private func stat(value: Int, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(value)")
                .font(.headline.weight(.black))
                .foregroundStyle(WidgetComicStyle.ink)

            Text(label.uppercased())
                .font(.caption2.weight(.black))
                .foregroundStyle(WidgetComicStyle.ink.opacity(0.8))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(WidgetComicStyle.panel, in: RoundedRectangle(cornerRadius: 5))
        .overlay(RoundedRectangle(cornerRadius: 5).stroke(WidgetComicStyle.ink, lineWidth: 1.5))
    }
}

struct BooksCollectorWidget: Widget {
    let kind = "BooksCollectorWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CollectorWidgetProvider(kind: .books)) { entry in
            BookReadingWidgetView(entry: entry)
        }
        .configurationDisplayName("Got it Books")
        .description("Reading, wishlist, and next book.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ComicsCollectorWidget: Widget {
    let kind = "ComicsCollectorWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CollectorWidgetProvider(kind: .comics)) { entry in
            CollectorWidgetView(entry: entry)
        }
        .configurationDisplayName("Got it Comics")
        .description("Comic issues, missing gaps, and current reading.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct GamesCollectorWidget: Widget {
    let kind = "GamesCollectorWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CollectorWidgetProvider(kind: .games)) { entry in
            CollectorWidgetView(entry: entry)
        }
        .configurationDisplayName("Got it Games")
        .description("Backlog, completed games, and quick picks.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct VinylCollectorWidget: Widget {
    let kind = "VinylCollectorWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CollectorWidgetProvider(kind: .vinyl)) { entry in
            CollectorWidgetView(entry: entry)
        }
        .configurationDisplayName("Got it Vinyl")
        .description("Collection, wishlist, and something to play.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct CollectorWidgetsBundle: WidgetBundle {
    var body: some Widget {
        BooksCollectorWidget()
        ComicsCollectorWidget()
        GamesCollectorWidget()
        VinylCollectorWidget()
    }
}

enum CollectorWidgetKind {
    case books
    case comics
    case games
    case vinyl

    var placeholder: WidgetMetricSnapshot {
        switch self {
        case .books:
            WidgetMetricSnapshot(title: "Books", primaryValue: 1, secondaryValue: 3, primaryLabel: "Reading", secondaryLabel: "Wishlist", highlightTitle: "Current book", highlightSubtitle: "Next: unread pick", progress: 0.4)
        case .comics:
            WidgetMetricSnapshot(title: "Comics", primaryValue: 18, secondaryValue: 4, primaryLabel: "Have", secondaryLabel: "Missing", highlightTitle: "Current issue", highlightSubtitle: "Gaps: series", progress: 0.82)
        case .games:
            WidgetMetricSnapshot(title: "Games", primaryValue: 12, secondaryValue: 7, primaryLabel: "Backlog", secondaryLabel: "Done", highlightTitle: "Playing now", highlightSubtitle: "Quick pick: short game", progress: 0.36)
        case .vinyl:
            WidgetMetricSnapshot(title: "Vinyl", primaryValue: 32, secondaryValue: 5, primaryLabel: "Owned", secondaryLabel: "Wishlist", highlightTitle: "Spin today", highlightSubtitle: "Wishlist: wanted record", progress: 0.86)
        }
    }
}
