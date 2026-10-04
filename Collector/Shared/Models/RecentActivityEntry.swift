import Foundation

struct RecentActivityEntry: Identifiable, Hashable {
    let categoryID: UUID
    let groupID: UUID?
    let item: CollectibleItem
    let categoryTitle: String
    let groupTitle: String?

    var id: String {
        "\(categoryID.uuidString)-\(groupID?.uuidString ?? "root")-\(item.id.uuidString)"
    }

    var activityDate: Date {
        item.updatedAt ?? item.createdAt
    }

    var route: CollectorRoute {
        .item(categoryID: categoryID, groupID: groupID, itemID: item.id)
    }
}
