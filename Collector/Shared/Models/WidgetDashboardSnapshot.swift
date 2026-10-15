import Foundation

struct WidgetDashboardSnapshot: Codable, Hashable {
    let books: WidgetMetricSnapshot
    let comics: WidgetMetricSnapshot
    let games: WidgetMetricSnapshot
    let vinyl: WidgetMetricSnapshot
    let updatedAt: Date
    var readingBooks: [ReadingBookWidgetItem]? = nil
    var followedComic: FollowedComicWidgetItem? = nil
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

struct FollowedComicWidgetItem: Codable, Hashable {
    let categoryID: UUID
    let groupID: UUID
    let title: String
    let ownedCount: Int
    let missingCount: Int
    let coverData: Data?

    var progress: Double {
        let total = ownedCount + missingCount
        return total > 0 ? Double(ownedCount) / Double(total) : 0
    }

    var url: URL? { URL(string: "gotit://comics/\(categoryID.uuidString)/\(groupID.uuidString)") }
}
