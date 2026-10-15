import Foundation

struct CollectionGroup: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var subtitle: String
    var groups: [CollectionGroup]
    var items: [CollectibleItem]
    var isFollowing: Bool? = nil

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String = "",
        groups: [CollectionGroup] = [],
        items: [CollectibleItem] = [],
        isFollowing: Bool? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.groups = groups
        self.items = items
        self.isFollowing = isFollowing
    }
}
