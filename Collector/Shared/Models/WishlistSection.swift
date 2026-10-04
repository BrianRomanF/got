import Foundation

struct WishlistSection: Identifiable, Hashable {
    let id: String
    let categoryID: UUID
    let categoryTitle: String
    let groupID: UUID?
    let title: String
    let entries: [WishlistEntry]

    var count: Int {
        entries.count
    }
}
