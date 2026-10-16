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
        switch template {
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
    static func dayKey(for date: Date, calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.era, .year, .month, .day], from: date)
        return "\(parts.era ?? 0)-\(parts.year ?? 0)-\(parts.month ?? 0)-\(parts.day ?? 0)"
    }

    static func suggestions(in categories: [CollectionCategory], date: Date, calendar: Calendar) -> [HomeDiscoverySuggestion] {
        let candidates = categories.flatMap { category in
            suggestions(items: category.items, groups: category.groups, category: category, groupID: nil)
        }
        let ordered = candidates.sorted {
            let left = score(id: $0.id)
            let right = score(id: $1.id)
            return left == right ? $0.id.uuidString < $1.id.uuidString : left > right
        }
        guard !ordered.isEmpty else { return [] }
        let day = calendar.ordinality(of: .day, in: .era, for: date) ?? 0
        let offset = day % ordered.count
        return Array(ordered.dropFirst(offset)) + Array(ordered.prefix(offset))
    }

    private static func suggestions(items: [CollectibleItem], groups: [CollectionGroup], category: CollectionCategory, groupID: UUID?) -> [HomeDiscoverySuggestion] {
        let owned = items.filter { $0.ownershipStatus == .owned }.map {
            HomeDiscoverySuggestion(categoryID: category.id, categoryTitle: category.title, groupID: groupID, template: category.template, item: $0)
        }
        return owned + groups.flatMap { group in
            suggestions(items: group.items, groups: group.groups, category: category, groupID: group.id)
        }
    }

    private static func score(id: UUID) -> UInt64 {
        var value: UInt64 = 14_695_981_039_346_656_037
        for byte in ("discovery|" + id.uuidString).utf8 {
            value = (value ^ UInt64(byte)) &* 1_099_511_628_211
        }
        return value
    }
}
