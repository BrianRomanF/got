import Foundation

enum CollectorRoute: Hashable {
    case category(UUID)
    case group(categoryID: UUID, groupID: UUID)
    case item(categoryID: UUID, groupID: UUID?, itemID: UUID)
    case wishlist
    case wishlistCategory(UUID)
    case wishlistSection(sectionID: String)
}
