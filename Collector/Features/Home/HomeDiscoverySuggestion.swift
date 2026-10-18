import Foundation

struct HomeDiscoverySuggestion: Identifiable, Hashable {
    let categoryID: UUID
    let categoryTitle: String
    let groupID: UUID?
    let template: CollectionTemplate
    let item: CollectibleItem

    var id: UUID { item.id }
    var route: CollectorRoute { .item(categoryID: categoryID, groupID: groupID, itemID: item.id) }

    var prompt: String {
        if item.ownershipStatus == .missing { return L10n.HomeDiscovery.missing }
        return switch template {
        case .vinyl: L10n.HomeDiscovery.listen
        case .books:
            switch item.readingStatus {
            case .reading: L10n.HomeDiscovery.continueBook
            case .read: L10n.HomeDiscovery.rereadBook
            default: L10n.HomeDiscovery.nextBook
            }
        case .comics:
            switch item.readingStatus {
            case .reading: L10n.HomeDiscovery.continueComic
            case .read: L10n.HomeDiscovery.rereadComic
            default: L10n.HomeDiscovery.nextComic
            }
        case .games: L10n.HomeDiscovery.play
        case .tradingCards, .collectibles, .custom: L10n.HomeDiscovery.rediscover
        }
    }
}

enum HomeDiscoverySelection {
    static func suggestions(in categories: [CollectionCategory]) -> [HomeDiscoverySuggestion] {
        categories.flatMap { category in
            suggestions(items: category.items, groups: category.groups, category: category, groupID: nil)
        }
    }

    private static func suggestions(items: [CollectibleItem], groups: [CollectionGroup], category: CollectionCategory, groupID: UUID?) -> [HomeDiscoverySuggestion] {
        let candidates = items.map {
            HomeDiscoverySuggestion(categoryID: category.id, categoryTitle: category.title, groupID: groupID, template: category.template, item: $0)
        }
        return candidates + groups.flatMap { group in
            suggestions(items: group.items, groups: group.groups, category: category, groupID: group.id)
        }
    }

}
