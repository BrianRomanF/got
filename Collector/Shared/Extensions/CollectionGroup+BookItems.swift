import Foundation

extension CollectionGroup {
    var allItems: [CollectibleItem] {
        items + groups.flatMap(\.allItems)
    }
}

extension CollectionCategory {
    var allItems: [CollectibleItem] {
        items + groups.flatMap(\.allItems)
    }
}
