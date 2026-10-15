import Foundation
import WidgetKit

enum WidgetDashboardPublisher {
    static let appGroupIdentifier = "group.com.brianroman.Collectorappmen"
    static let snapshotKey = "collector.widgetDashboardSnapshot"

    static func publish(categories: [CollectionCategory]) {
        guard FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) != nil else { return }
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else { return }

        let snapshot = WidgetDashboardSnapshot.make(from: categories)

        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: snapshotKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
