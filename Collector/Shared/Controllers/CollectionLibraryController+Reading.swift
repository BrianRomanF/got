import Foundation

struct BookReadingLocation {
    let categoryID: UUID
    let groupID: UUID?
    let item: CollectibleItem
}

extension CollectionLibraryController {
    var readingBooks: [BookReadingLocation] {
        bookLocations.filter { $0.item.ownershipStatus == .owned && $0.item.readingStatus == .reading }
            .sorted { ($0.item.updatedAt ?? $0.item.createdAt) > ($1.item.updatedAt ?? $1.item.createdAt) }
    }

    func bookLocation(id: UUID?) -> BookReadingLocation? {
        if let id { return bookLocations.first { $0.item.id == id } }
        return readingBooks.first
    }

    private var bookLocations: [BookReadingLocation] {
        categories.filter { $0.template == .books }.flatMap { category in
            category.items.map { BookReadingLocation(categoryID: category.id, groupID: nil, item: $0) }
                + bookLocations(in: category.groups, categoryID: category.id)
        }
    }

    private func bookLocations(in groups: [CollectionGroup], categoryID: UUID) -> [BookReadingLocation] {
        groups.flatMap { group in
            group.items.map { BookReadingLocation(categoryID: categoryID, groupID: group.id, item: $0) }
                + bookLocations(in: group.groups, categoryID: categoryID)
        }
    }
}
