import Foundation

enum CollectorRoute: Hashable {
    case globalSearch
    case recentActivity
    case recentActivityCategory(UUID)
    case recentActivitySection(sectionID: String)
    case category(UUID)
    case group(categoryID: UUID, groupID: UUID)
    case item(categoryID: UUID, groupID: UUID?, itemID: UUID)
    case wishlist
    case wishlistCategory(UUID)
    case wishlistSection(sectionID: String)
}
