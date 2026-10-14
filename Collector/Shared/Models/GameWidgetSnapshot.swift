import Foundation

struct GameWidgetSnapshot: Hashable {
    let platformCount: Int
    let totalGames: Int
    let ownedGames: Int
    let wishlistCount: Int
    let completedCount: Int
    let backlogCount: Int
    let currentGame: CollectibleItem?
    let shortBacklogGame: CollectibleItem?

    var completionRatio: Double {
        guard ownedGames > 0 else { return 0 }
        return Double(completedCount) / Double(ownedGames)
    }

    init(category: CollectionCategory) {
        self.init(groups: category.groups, items: category.allItems)
    }

    init(group: CollectionGroup) {
        self.init(groups: group.groups, items: group.allItems)
    }

    private init(groups: [CollectionGroup], items: [CollectibleItem]) {
        let owned = items.filter { $0.ownershipStatus == .owned }
        let wishlist = items.filter { $0.ownershipStatus == .missing }
        let completed = owned.filter { $0.resolvedGameBacklogStatus.isDone }
        let backlog = owned.filter { !$0.resolvedGameBacklogStatus.isDone && $0.resolvedGameBacklogStatus != .abandoned }

        platformCount = groups.isEmpty ? Set(items.compactMap(\.gamePlatform)).count : groups.count
        totalGames = items.count
        ownedGames = owned.count
        wishlistCount = wishlist.count
        completedCount = completed.count
        backlogCount = backlog.count
        currentGame = owned
            .filter { $0.resolvedGameBacklogStatus == .playing }
            .sortedByRecentActivity()
            .first
        shortBacklogGame = backlog.firstTagged(withAnyOf: ["corto", "short", "quick"]) ?? backlog.sortedByRecentActivity().first
    }
}

private extension CollectibleItem {
    var gamePlatform: String? {
        templateDetails?["platform"]?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
