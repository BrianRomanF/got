import Foundation

struct VinylWidgetSnapshot: Hashable {
    let styleCount: Int
    let totalReleases: Int
    let ownedReleases: Int
    let wishlistCount: Int
    let withConditionCount: Int
    let withPressingCount: Int
    let featuredRelease: CollectibleItem?
    let wishlistPreview: CollectibleItem?

    var catalogRatio: Double {
        guard totalReleases > 0 else { return 0 }
        return Double(ownedReleases) / Double(totalReleases)
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

        styleCount = groups.isEmpty ? Set(items.flatMap(\.tags)).count : groups.count
        totalReleases = items.count
        ownedReleases = owned.count
        wishlistCount = wishlist.count
        withConditionCount = owned.filter { item in
            (item.vinylMediaCondition?.isKnown ?? false) || (item.vinylSleeveCondition?.isKnown ?? false)
        }.count
        withPressingCount = owned.filter { $0.hasTemplateDetail("pressing") }.count
        featuredRelease = owned.firstTagged(withAnyOf: ["escuchar", "listen", "favorito", "favorite"]) ?? owned.sortedByRecentActivity().first
        wishlistPreview = wishlist.sortedByRecentActivity().first
    }
}

private extension CollectibleItem {
    func hasTemplateDetail(_ key: String) -> Bool {
        guard let value = templateDetails?[key]?.trimmingCharacters(in: .whitespacesAndNewlines) else { return false }
        return !value.isEmpty
    }
}
