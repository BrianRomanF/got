import Foundation

struct WidgetDashboardSnapshot: Codable, Hashable {
    let books: WidgetMetricSnapshot
    let comics: WidgetMetricSnapshot
    let games: WidgetMetricSnapshot
    let vinyl: WidgetMetricSnapshot
    let updatedAt: Date
    var readingBooks: [ReadingBookWidgetItem]? = nil
}

struct ReadingBookWidgetItem: Codable, Hashable, Identifiable {
    let id: UUID
    let title: String
    let currentPage: Int
    let totalPages: Int?
    let progress: Double
    let coverData: Data?

    var url: URL? { URL(string: "gotit://reading/\(id.uuidString)") }
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
