import SwiftUI
import WidgetKit

private let appGroupIdentifier = "group.com.brianroman.Collectorappmen"
private let snapshotKey = "collector.widgetDashboardSnapshot"

struct CollectorWidgetEntry: TimelineEntry {
    let date: Date
    let metric: WidgetMetricSnapshot
}

struct CollectorWidgetProvider: TimelineProvider {
    let kind: CollectorWidgetKind

    func placeholder(in context: Context) -> CollectorWidgetEntry {
        CollectorWidgetEntry(date: .now, metric: kind.placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (CollectorWidgetEntry) -> Void) {
        completion(CollectorWidgetEntry(date: .now, metric: metric()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CollectorWidgetEntry>) -> Void) {
        let entry = CollectorWidgetEntry(date: .now, metric: metric())
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now.addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func metric() -> WidgetMetricSnapshot {
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
    }
}

struct CollectorWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: CollectorWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(entry.metric.title.uppercased())
                    .font(.caption.weight(.black))
                    .foregroundStyle(.red)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Text("\(Int(entry.metric.progress * 100))%")
                    .font(.title3.weight(.black))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.7)
            }

            progressBar

            HStack(spacing: 8) {
                stat(value: entry.metric.primaryValue, label: entry.metric.primaryLabel)
                stat(value: entry.metric.secondaryValue, label: entry.metric.secondaryLabel)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.metric.highlightTitle)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.primary)
                    .lineLimit(family == .systemSmall ? 2 : 1)
                    .minimumScaleFactor(0.75)

                Text(entry.metric.highlightSubtitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .containerBackground(Color(red: 1.0, green: 0.94, blue: 0.72), for: .widget)
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.8))
                Capsule()
                    .fill(Color.green)
                    .frame(width: entry.metric.progress > 0 ? max(8, proxy.size.width * entry.metric.progress) : 0)
            }
        }
        .frame(height: 8)
    }

    private func stat(value: Int, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(value)")
                .font(.title3.weight(.black))
                .foregroundStyle(.primary)

            Text(label.uppercased())
                .font(.caption2.weight(.black))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct BooksCollectorWidget: Widget {
    let kind = "BooksCollectorWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CollectorWidgetProvider(kind: .books)) { entry in
            CollectorWidgetView(entry: entry)
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
