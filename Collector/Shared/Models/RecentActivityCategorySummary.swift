import Foundation

struct RecentActivityCategorySummary: Identifiable, Hashable {
    let id: UUID
    let title: String
    let sections: [RecentActivitySection]

    var count: Int {
        sections.reduce(0) { $0 + $1.count }
    }

    var latestDate: Date? {
        sections.compactMap(\.latestDate).max()
    }
}
