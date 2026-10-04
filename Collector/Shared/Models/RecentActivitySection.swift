import Foundation

struct RecentActivitySection: Identifiable, Hashable {
    let id: String
    let categoryID: UUID
    let categoryTitle: String
    let groupID: UUID?
    let title: String
    let entries: [RecentActivityEntry]

    var count: Int {
        entries.count
    }

    var latestDate: Date? {
        entries.map(\.activityDate).max()
    }
}
