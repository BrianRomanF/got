import Foundation

struct WishlistEntry: Identifiable, Hashable {
    let id: String
    let categoryID: UUID
    let groupID: UUID?
    let item: CollectibleItem
    let categoryTitle: String
    let groupTitle: String?

    init(categoryID: UUID, groupID: UUID?, item: CollectibleItem, categoryTitle: String, groupTitle: String?) {
        self.id = "\(categoryID.uuidString)-\(groupID?.uuidString ?? "root")-\(item.id.uuidString)"
        self.categoryID = categoryID
        self.groupID = groupID
        self.item = item
        self.categoryTitle = categoryTitle
        self.groupTitle = groupTitle
    }
}
