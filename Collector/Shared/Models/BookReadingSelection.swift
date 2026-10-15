import Foundation

enum BookReadingSelection {
    static func normalize(_ categories: [CollectionCategory], previous: [CollectionCategory]? = nil) -> [CollectionCategory] {
        let reading = categories.filter { $0.template == .books }.flatMap(\.allItems)
            .filter { $0.ownershipStatus == .owned && $0.readingStatus == .reading }
            .sorted {
                let left = $0.updatedAt ?? $0.createdAt
                let right = $1.updatedAt ?? $1.createdAt
                return left == right ? $0.id.uuidString < $1.id.uuidString : left > right
            }
        guard reading.count > 1 else { return categories }

        let previousCategories = previous ?? categories
        let previousBooks = previousCategories.filter { $0.template == .books }.flatMap(\.allItems)
        let previousReading = previousBooks.filter { $0.ownershipStatus == .owned && $0.readingStatus == .reading }
        let previousIDs = Set<UUID>(previousReading.map(\.id))
        let selectedID = (reading.first { !previousIDs.contains($0.id) } ?? reading[0]).id

        return categories.map { category in
            guard category.template == .books else { return category }
            var category = category
            category.items = normalize(category.items, selectedID: selectedID)
            category.groups = normalize(category.groups, selectedID: selectedID)
            return category
        }
    }

    private static func normalize(_ items: [CollectibleItem], selectedID: UUID) -> [CollectibleItem] {
        items.map { item in
            guard item.id != selectedID, item.ownershipStatus == .owned, item.readingStatus == .reading else { return item }
            var item = item
            item.readingStatus = .unread
            return item
        }
    }

    private static func normalize(_ groups: [CollectionGroup], selectedID: UUID) -> [CollectionGroup] {
        groups.map { group in
            var group = group
            group.items = normalize(group.items, selectedID: selectedID)
            group.groups = normalize(group.groups, selectedID: selectedID)
            return group
        }
    }
}
