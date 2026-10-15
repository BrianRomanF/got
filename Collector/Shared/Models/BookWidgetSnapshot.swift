import Foundation

struct BookWidgetSnapshot: Hashable {
    let totalCount: Int
    let ownedCount: Int
    let readingCount: Int
    let readCount: Int
    let unreadCount: Int
    let wishlistCount: Int
    let currentBook: CollectibleItem?
    let nextBook: CollectibleItem?
    let wishlistPreview: [CollectibleItem]

    var hasBooks: Bool {
        totalCount > 0
    }

    var completionRatio: Double {
        guard ownedCount > 0 else { return 0 }
        return Double(readCount) / Double(ownedCount)
    }

    init(items: [CollectibleItem]) {
        let ownedItems = items.filter { $0.ownershipStatus == .owned }
        let wishlistItems = items.filter { $0.ownershipStatus == .missing }
        let readingItems = ownedItems.filter { $0.readingStatus == .reading }
        let unreadItems = ownedItems.filter { $0.readingStatus == .unread || $0.readingStatus == nil }
        let readItems = ownedItems.filter { $0.readingStatus == .read }

        totalCount = items.count
        ownedCount = ownedItems.count
        readingCount = readingItems.count
        readCount = readItems.count
        unreadCount = unreadItems.count
        wishlistCount = wishlistItems.count
        currentBook = readingItems.sorted {
            ($0.updatedAt ?? $0.createdAt) > ($1.updatedAt ?? $1.createdAt)
        }
        .first
        nextBook = unreadItems.sortedByRecentActivity().first
        wishlistPreview = Array(wishlistItems.sortedByRecentActivity().prefix(3))
    }
}
