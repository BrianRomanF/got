import Foundation

struct WidgetDashboardSnapshot: Codable, Hashable {
    let books: WidgetMetricSnapshot
    let comics: WidgetMetricSnapshot
    let games: WidgetMetricSnapshot
    let vinyl: WidgetMetricSnapshot
    let updatedAt: Date
}

struct WidgetMetricSnapshot: Codable, Hashable {
    let title: String
    let primaryValue: Int
    let secondaryValue: Int
    let primaryLabel: String
    let secondaryLabel: String
    let highlightTitle: String
    let highlightSubtitle: String
    let progress: Double
}
