import Foundation

struct CollectionGroup: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var subtitle: String
    var groups: [CollectionGroup]
    var items: [CollectibleItem]

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String = "",
        groups: [CollectionGroup] = [],
        items: [CollectibleItem] = []
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.groups = groups
        self.items = items
    }
}
