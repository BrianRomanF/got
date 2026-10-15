import Foundation

struct VinylAlbumLocation {
    let categoryID: UUID
    let groupID: UUID?
    let item: CollectibleItem
}

enum VinylFavoriteSelection {
    static func locations(in categories: [CollectionCategory]) -> [VinylAlbumLocation] {
        categories.filter { $0.template == .vinyl }.flatMap { category in
            category.items.map { VinylAlbumLocation(categoryID: category.id, groupID: nil, item: $0) }
                + locations(in: category.groups, categoryID: category.id)
        }
    }

    static func featuredAlbum(in categories: [CollectionCategory]) -> VinylAlbumLocation? {
        let albums = locations(in: categories)
        let items = albums.map(\.item).sortedByRecentActivity()
        let owned = items.filter { $0.ownershipStatus == .owned }
        guard let item = items.first(where: { $0.isFavorite == true })
            ?? owned.firstTagged(withAnyOf: ["escuchar", "listen", "favorito", "favorite"])
            ?? owned.first else { return nil }
        return albums.first { $0.item.id == item.id }
    }

    static func selecting(itemID: UUID?, in categories: [CollectionCategory]) -> [CollectionCategory] {
        categories.map { category in
            guard category.template == .vinyl else { return category }
            var category = category
            category.items = selecting(itemID: itemID, in: category.items)
            category.groups = selecting(itemID: itemID, in: category.groups)
            return category
        }
    }

    private static func locations(in groups: [CollectionGroup], categoryID: UUID) -> [VinylAlbumLocation] {
        groups.flatMap { group in
            group.items.map { VinylAlbumLocation(categoryID: categoryID, groupID: group.id, item: $0) }
                + locations(in: group.groups, categoryID: categoryID)
        }
    }

    private static func selecting(itemID: UUID?, in items: [CollectibleItem]) -> [CollectibleItem] {
        items.map { item in
            var item = item
            item.isFavorite = item.id == itemID ? true : nil
            return item
        }
    }

    private static func selecting(itemID: UUID?, in groups: [CollectionGroup]) -> [CollectionGroup] {
        groups.map { group in
            var group = group
            group.items = selecting(itemID: itemID, in: group.items)
            group.groups = selecting(itemID: itemID, in: group.groups)
            return group
        }
    }
}
