import Foundation

final class CollectionLibraryController: ObservableObject {
    @Published private(set) var categories: [CollectionCategory] {
        didSet {
            persistence.saveCategories(categories)
        }
    }

    private let persistence: CollectionLibraryPersistenceController

    init(
        categories: [CollectionCategory]? = nil,
        persistence: CollectionLibraryPersistenceController = .shared
    ) {
        self.persistence = persistence
        self.categories = categories
            ?? persistence.loadCategories()
            ?? CollectionLibraryController.seedCategories
    }

    func category(with id: UUID) -> CollectionCategory? {
        categories.first { $0.id == id }
    }

    func group(with id: UUID, in categoryID: UUID) -> CollectionGroup? {
        guard let category = category(with: categoryID) else { return nil }
        return findGroup(id, in: category.groups)
    }

    func item(with itemID: UUID, inCategory categoryID: UUID, groupID: UUID?) -> CollectibleItem? {
        guard let category = category(with: categoryID) else { return nil }

        if let groupID {
            return findGroup(groupID, in: category.groups)?.items.first { $0.id == itemID }
        }

        return category.items.first { $0.id == itemID }
    }

    func addCategory(
        title: String,
        subtitle: String,
        template: CollectionTemplate = .custom,
        customContentMode: CustomCategoryContentMode = .shelvesAndPieces,
        symbolName: String? = nil,
        svgIconPath: String? = nil,
        svgIconRemoteURL: URL? = nil
    ) {
        let category = CollectionCategory(
            title: title,
            subtitle: subtitle,
            symbolName: symbolName ?? template.defaultSymbolName,
            svgIconPath: svgIconPath,
            svgIconRemoteURL: svgIconRemoteURL,
            template: template,
            customContentMode: customContentMode
        )
        categories.append(category)
    }

    func deleteCategory(with categoryID: UUID) {
        categories.removeAll { $0.id == categoryID }
    }

    func exportLibrary() -> URL? {
        persistence.exportCategories(categories)
    }

    func importLibrary(from fileURL: URL) -> Bool {
        do {
            categories = try persistence.loadCategories(from: fileURL)
            return true
        } catch {
            return false
        }
    }

    func updateCategory(
        with categoryID: UUID,
        title: String,
        subtitle: String,
        template: CollectionTemplate,
        customContentMode: CustomCategoryContentMode,
        svgIconPath: String?,
        svgIconRemoteURL: URL?
    ) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else { return }
        categories[categoryIndex].title = title
        categories[categoryIndex].subtitle = subtitle
        categories[categoryIndex].template = template
        categories[categoryIndex].customContentMode = customContentMode
        categories[categoryIndex].symbolName = template.defaultSymbolName
        categories[categoryIndex].svgIconPath = svgIconPath
        categories[categoryIndex].svgIconRemoteURL = svgIconRemoteURL
    }

    func addGroup(title: String, subtitle: String = "", toCategory categoryID: UUID) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else { return }
        categories[categoryIndex].groups.append(CollectionGroup(title: title, subtitle: subtitle))
    }

    func addGroup(_ group: CollectionGroup, toCategory categoryID: UUID) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else { return }
        categories[categoryIndex].groups.append(group)
    }

    func addGroup(title: String, subtitle: String = "", toParent parentID: UUID, inCategory categoryID: UUID) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else { return }
        insertGroup(CollectionGroup(title: title, subtitle: subtitle), parentID: parentID, groups: &categories[categoryIndex].groups)
    }

    func deleteGroup(with groupID: UUID, inCategory categoryID: UUID) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else { return }
        deleteGroup(with: groupID, groups: &categories[categoryIndex].groups)
    }

    func moveGroup(with groupID: UUID, direction: GroupMoveDirection, inCategory categoryID: UUID, parentGroupID: UUID? = nil) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else { return }

        if let parentGroupID {
            moveGroup(with: groupID, direction: direction, parentGroupID: parentGroupID, groups: &categories[categoryIndex].groups)
            return
        }

        moveGroup(with: groupID, direction: direction, groups: &categories[categoryIndex].groups)
    }

    func items(inCategory categoryID: UUID, groupID: UUID?) -> [CollectibleItem] {
        guard let category = category(with: categoryID) else { return [] }

        if let groupID {
            return findGroup(groupID, in: category.groups)?.items ?? []
        }

        return category.items
    }

    func stats(for category: CollectionCategory) -> CollectionStats {
        stats(items: category.items, groups: category.groups)
    }

    func libraryStats() -> CollectionStats {
        categories.reduce(CollectionStats(totalItems: 0, ownedItems: 0, missingItems: 0, groups: 0)) { partial, category in
            let categoryStats = stats(for: category)
            return CollectionStats(
                totalItems: partial.totalItems + categoryStats.totalItems,
                ownedItems: partial.ownedItems + categoryStats.ownedItems,
                missingItems: partial.missingItems + categoryStats.missingItems,
                groups: partial.groups + categoryStats.groups
            )
        }
    }

    func wishlistEntries() -> [WishlistEntry] {
        categories.flatMap { category in
            wishlistEntries(in: category)
        }
    }

    func wishlistSections() -> [(category: CollectionCategory, sections: [WishlistSection])] {
        categories.compactMap { category in
            let sections = wishlistSections(in: category)
            guard !sections.isEmpty else { return nil }
            return (category, sections)
        }
    }

    func wishlistCategorySummaries() -> [WishlistCategorySummary] {
        wishlistSections().map { grouped in
            WishlistCategorySummary(
                id: grouped.category.id,
                title: grouped.category.title,
                sections: grouped.sections
            )
        }
    }

    func wishlistSections(inCategory categoryID: UUID) -> [WishlistSection] {
        guard let category = category(with: categoryID) else { return [] }
        return wishlistSections(in: category)
    }

    func wishlistSection(with sectionID: String) -> WishlistSection? {
        wishlistSections()
            .flatMap(\.sections)
            .first { $0.id == sectionID }
    }

    func globalSearchResults(query: String) -> [GlobalSearchResult] {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedQuery.isEmpty else { return [] }

        var results: [GlobalSearchResult] = []

        for category in categories {
            if matches(normalizedQuery, in: [category.title, category.subtitle]) {
                results.append(
                    GlobalSearchResult(
                        id: "category-\(category.id.uuidString)",
                        kind: .category,
                        title: category.title,
                        subtitle: category.subtitle,
                        route: .category(category.id)
                    )
                )
            }

            results.append(contentsOf: globalSearchResults(
                query: normalizedQuery,
                items: category.items,
                categoryID: category.id,
                categoryTitle: category.title,
                groupID: nil,
                path: category.title
            ))

            results.append(contentsOf: globalSearchResults(
                query: normalizedQuery,
                groups: category.groups,
                categoryID: category.id,
                categoryTitle: category.title,
                path: category.title
            ))
        }

        return Array(results.prefix(60))
    }

    func recentActivity(limit: Int = 20) -> [RecentActivityEntry] {
        categories
            .flatMap { category in
                recentActivityEntries(in: category)
            }
            .sorted { $0.activityDate > $1.activityDate }
            .prefix(limit)
            .map { $0 }
    }

    func recentActivityCategorySummaries() -> [RecentActivityCategorySummary] {
        categories.compactMap { category in
            let sections = recentActivitySections(in: category)
            guard !sections.isEmpty else { return nil }
            return RecentActivityCategorySummary(
                id: category.id,
                title: category.title,
                sections: sections
            )
        }
        .sorted { ($0.latestDate ?? .distantPast) > ($1.latestDate ?? .distantPast) }
    }

    func recentActivitySections(inCategory categoryID: UUID) -> [RecentActivitySection] {
        guard let category = category(with: categoryID) else { return [] }
        return recentActivitySections(in: category)
    }

    func recentActivitySection(with sectionID: String) -> RecentActivitySection? {
        recentActivityCategorySummaries()
            .flatMap(\.sections)
            .first { $0.id == sectionID }
    }

    func addItem(_ item: CollectibleItem, toCategory categoryID: UUID) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else { return }
        categories[categoryIndex].items.append(item)
    }

    func addItem(_ item: CollectibleItem, toGroup groupID: UUID, inCategory categoryID: UUID) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else { return }
        insertItem(item, groupID: groupID, groups: &categories[categoryIndex].groups)
    }

    func updateItem(_ item: CollectibleItem, inCategory categoryID: UUID, groupID: UUID?) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else { return }
        var updatedItem = item
        updatedItem.updatedAt = .now

        if let groupID {
            updateItem(updatedItem, groupID: groupID, groups: &categories[categoryIndex].groups)
            return
        }

        guard let itemIndex = categories[categoryIndex].items.firstIndex(where: { $0.id == item.id }) else { return }
        categories[categoryIndex].items[itemIndex] = updatedItem
    }

    func updateItemOwnership(itemID: UUID, status: ItemOwnershipStatus, inCategory categoryID: UUID, groupID: UUID?) {
        guard var item = item(with: itemID, inCategory: categoryID, groupID: groupID) else { return }
        item.ownershipStatus = status
        updateItem(item, inCategory: categoryID, groupID: groupID)
    }

    func deleteItem(with itemID: UUID, inCategory categoryID: UUID, groupID: UUID?) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else { return }

        if let groupID {
            deleteItem(with: itemID, groupID: groupID, groups: &categories[categoryIndex].groups)
            return
        }

        categories[categoryIndex].items.removeAll { $0.id == itemID }
    }

    private func findGroup(_ id: UUID, in groups: [CollectionGroup]) -> CollectionGroup? {
        for group in groups {
            if group.id == id {
                return group
            }

            if let child = findGroup(id, in: group.groups) {
                return child
            }
        }

        return nil
    }

    private func stats(items: [CollectibleItem], groups: [CollectionGroup]) -> CollectionStats {
        let directOwned = items.filter { $0.ownershipStatus == .owned }.count
        let directMissing = items.filter { $0.ownershipStatus == .missing }.count

        return groups.reduce(
            CollectionStats(
                totalItems: items.count,
                ownedItems: directOwned,
                missingItems: directMissing,
                groups: groups.count
            )
        ) { partial, group in
            let groupStats = stats(items: group.items, groups: group.groups)
            return CollectionStats(
                totalItems: partial.totalItems + groupStats.totalItems,
                ownedItems: partial.ownedItems + groupStats.ownedItems,
                missingItems: partial.missingItems + groupStats.missingItems,
                groups: partial.groups + groupStats.groups
            )
        }
    }

    private func wishlistEntries(in category: CollectionCategory) -> [WishlistEntry] {
        category.items
            .filter { $0.ownershipStatus == .missing }
            .map {
                WishlistEntry(
                    categoryID: category.id,
                    groupID: nil,
                    item: $0,
                    categoryTitle: category.title,
                    groupTitle: nil
                )
            }
            + wishlistEntries(
                in: category.groups,
                categoryID: category.id,
                categoryTitle: category.title
            )
    }

    private func wishlistSections(in category: CollectionCategory) -> [WishlistSection] {
        var sections: [WishlistSection] = []

        let rootEntries = category.items
            .filter { $0.ownershipStatus == .missing }
            .map {
                WishlistEntry(
                    categoryID: category.id,
                    groupID: nil,
                    item: $0,
                    categoryTitle: category.title,
                    groupTitle: nil
                )
            }

        if !rootEntries.isEmpty {
            sections.append(
                WishlistSection(
                    id: "\(category.id.uuidString)-root",
                    categoryID: category.id,
                    categoryTitle: category.title,
                    groupID: nil,
                    title: L10n.Wishlist.noShelf,
                    entries: rootEntries
                )
            )
        }

        sections.append(contentsOf: wishlistSections(in: category.groups, categoryID: category.id, categoryTitle: category.title))
        return sections
    }

    private func wishlistSections(in groups: [CollectionGroup], categoryID: UUID, categoryTitle: String) -> [WishlistSection] {
        groups.flatMap { group in
            var sections: [WishlistSection] = []
            let entries = group.items
                .filter { $0.ownershipStatus == .missing }
                .map {
                    WishlistEntry(
                        categoryID: categoryID,
                        groupID: group.id,
                        item: $0,
                        categoryTitle: categoryTitle,
                        groupTitle: group.title
                    )
                }

            if !entries.isEmpty {
                sections.append(
                    WishlistSection(
                        id: "\(categoryID.uuidString)-\(group.id.uuidString)",
                        categoryID: categoryID,
                        categoryTitle: categoryTitle,
                        groupID: group.id,
                        title: group.title,
                        entries: entries
                    )
                )
            }

            sections.append(contentsOf: wishlistSections(in: group.groups, categoryID: categoryID, categoryTitle: categoryTitle))
            return sections
        }
    }

    private func wishlistEntries(in groups: [CollectionGroup], categoryID: UUID, categoryTitle: String) -> [WishlistEntry] {
        groups.flatMap { group in
            group.items
                .filter { $0.ownershipStatus == .missing }
                .map {
                    WishlistEntry(
                        categoryID: categoryID,
                        groupID: group.id,
                        item: $0,
                        categoryTitle: categoryTitle,
                        groupTitle: group.title
                    )
                }
                + wishlistEntries(
                    in: group.groups,
                    categoryID: categoryID,
                    categoryTitle: categoryTitle
                )
        }
    }

    private func globalSearchResults(
        query: String,
        groups: [CollectionGroup],
        categoryID: UUID,
        categoryTitle: String,
        path: String
    ) -> [GlobalSearchResult] {
        groups.flatMap { group in
            let groupPath = [path, group.title].joined(separator: " > ")
            var results: [GlobalSearchResult] = []

            if matches(query, in: [group.title, group.subtitle]) {
                results.append(
                    GlobalSearchResult(
                        id: "group-\(categoryID.uuidString)-\(group.id.uuidString)",
                        kind: .shelf,
                        title: group.title,
                        subtitle: groupPath,
                        route: .group(categoryID: categoryID, groupID: group.id)
                    )
                )
            }

            results.append(contentsOf: globalSearchResults(
                query: query,
                items: group.items,
                categoryID: categoryID,
                categoryTitle: categoryTitle,
                groupID: group.id,
                path: groupPath
            ))

            results.append(contentsOf: globalSearchResults(
                query: query,
                groups: group.groups,
                categoryID: categoryID,
                categoryTitle: categoryTitle,
                path: groupPath
            ))

            return results
        }
    }

    private func globalSearchResults(
        query: String,
        items: [CollectibleItem],
        categoryID: UUID,
        categoryTitle: String,
        groupID: UUID?,
        path: String
    ) -> [GlobalSearchResult] {
        items.compactMap { item in
            let searchableValues = [
                item.title,
                item.subtitle,
                item.notes,
                item.physicalLocation ?? ""
            ] + (item.templateDetails?.map(\.value) ?? [])

            guard matches(query, in: searchableValues) else { return nil }

            return GlobalSearchResult(
                id: "item-\(categoryID.uuidString)-\(groupID?.uuidString ?? "root")-\(item.id.uuidString)",
                kind: .piece,
                title: item.title,
                subtitle: path,
                route: .item(categoryID: categoryID, groupID: groupID, itemID: item.id)
            )
        }
    }

    private func recentActivityEntries(in category: CollectionCategory) -> [RecentActivityEntry] {
        category.items.map {
            RecentActivityEntry(
                categoryID: category.id,
                groupID: nil,
                item: $0,
                categoryTitle: category.title,
                groupTitle: nil
            )
        }
        + recentActivityEntries(in: category.groups, categoryID: category.id, categoryTitle: category.title)
    }

    private func recentActivityEntries(in groups: [CollectionGroup], categoryID: UUID, categoryTitle: String) -> [RecentActivityEntry] {
        groups.flatMap { group in
            group.items.map {
                RecentActivityEntry(
                    categoryID: categoryID,
                    groupID: group.id,
                    item: $0,
                    categoryTitle: categoryTitle,
                    groupTitle: group.title
                )
            }
            + recentActivityEntries(in: group.groups, categoryID: categoryID, categoryTitle: categoryTitle)
        }
    }

    private func recentActivitySections(in category: CollectionCategory) -> [RecentActivitySection] {
        var sections: [RecentActivitySection] = []

        let rootEntries = category.items
            .map {
                RecentActivityEntry(
                    categoryID: category.id,
                    groupID: nil,
                    item: $0,
                    categoryTitle: category.title,
                    groupTitle: nil
                )
            }
            .sorted { $0.activityDate > $1.activityDate }

        if !rootEntries.isEmpty {
            sections.append(
                RecentActivitySection(
                    id: "\(category.id.uuidString)-root-recent",
                    categoryID: category.id,
                    categoryTitle: category.title,
                    groupID: nil,
                    title: L10n.RecentActivity.noShelf,
                    entries: rootEntries
                )
            )
        }

        sections.append(contentsOf: recentActivitySections(
            in: category.groups,
            categoryID: category.id,
            categoryTitle: category.title
        ))

        return sections.sorted { ($0.latestDate ?? .distantPast) > ($1.latestDate ?? .distantPast) }
    }

    private func recentActivitySections(in groups: [CollectionGroup], categoryID: UUID, categoryTitle: String) -> [RecentActivitySection] {
        groups.flatMap { group in
            var sections: [RecentActivitySection] = []
            let entries = group.items
                .map {
                    RecentActivityEntry(
                        categoryID: categoryID,
                        groupID: group.id,
                        item: $0,
                        categoryTitle: categoryTitle,
                        groupTitle: group.title
                    )
                }
                .sorted { $0.activityDate > $1.activityDate }

            if !entries.isEmpty {
                sections.append(
                    RecentActivitySection(
                        id: "\(categoryID.uuidString)-\(group.id.uuidString)-recent",
                        categoryID: categoryID,
                        categoryTitle: categoryTitle,
                        groupID: group.id,
                        title: group.title,
                        entries: entries
                    )
                )
            }

            sections.append(contentsOf: recentActivitySections(in: group.groups, categoryID: categoryID, categoryTitle: categoryTitle))
            return sections.sorted { ($0.latestDate ?? .distantPast) > ($1.latestDate ?? .distantPast) }
        }
    }

    private func matches(_ query: String, in values: [String]) -> Bool {
        values.contains { value in
            value.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }
    }

    @discardableResult
    private func insertGroup(_ group: CollectionGroup, parentID: UUID, groups: inout [CollectionGroup]) -> Bool {
        for index in groups.indices {
            if groups[index].id == parentID {
                groups[index].groups.append(group)
                return true
            }

            if insertGroup(group, parentID: parentID, groups: &groups[index].groups) {
                return true
            }
        }

        return false
    }

    @discardableResult
    private func deleteGroup(with groupID: UUID, groups: inout [CollectionGroup]) -> Bool {
        let originalCount = groups.count
        groups.removeAll { $0.id == groupID }

        if groups.count != originalCount {
            return true
        }

        for index in groups.indices {
            if deleteGroup(with: groupID, groups: &groups[index].groups) {
                return true
            }
        }

        return false
    }

    @discardableResult
    private func moveGroup(with groupID: UUID, direction: GroupMoveDirection, groups: inout [CollectionGroup]) -> Bool {
        guard let sourceIndex = groups.firstIndex(where: { $0.id == groupID }) else { return false }
        let destinationIndex = sourceIndex + direction.offset
        guard groups.indices.contains(destinationIndex) else { return false }

        let group = groups.remove(at: sourceIndex)
        groups.insert(group, at: destinationIndex)
        return true
    }

    @discardableResult
    private func moveGroup(with groupID: UUID, direction: GroupMoveDirection, parentGroupID: UUID, groups: inout [CollectionGroup]) -> Bool {
        for index in groups.indices {
            if groups[index].id == parentGroupID {
                return moveGroup(with: groupID, direction: direction, groups: &groups[index].groups)
            }

            if moveGroup(with: groupID, direction: direction, parentGroupID: parentGroupID, groups: &groups[index].groups) {
                return true
            }
        }

        return false
    }

    @discardableResult
    private func insertItem(_ item: CollectibleItem, groupID: UUID, groups: inout [CollectionGroup]) -> Bool {
        for index in groups.indices {
            if groups[index].id == groupID {
                groups[index].items.append(item)
                return true
            }

            if insertItem(item, groupID: groupID, groups: &groups[index].groups) {
                return true
            }
        }

        return false
    }

    @discardableResult
    private func updateItem(_ item: CollectibleItem, groupID: UUID, groups: inout [CollectionGroup]) -> Bool {
        for index in groups.indices {
            if groups[index].id == groupID,
               let itemIndex = groups[index].items.firstIndex(where: { $0.id == item.id }) {
                groups[index].items[itemIndex] = item
                return true
            }

            if updateItem(item, groupID: groupID, groups: &groups[index].groups) {
                return true
            }
        }

        return false
    }

    @discardableResult
    private func deleteItem(with itemID: UUID, groupID: UUID, groups: inout [CollectionGroup]) -> Bool {
        for index in groups.indices {
            if groups[index].id == groupID {
                let originalCount = groups[index].items.count
                groups[index].items.removeAll { $0.id == itemID }
                return groups[index].items.count != originalCount
            }

            if deleteItem(with: itemID, groupID: groupID, groups: &groups[index].groups) {
                return true
            }
        }

        return false
    }
}

private extension CollectionLibraryController {
    static let seedCategories: [CollectionCategory] = [
        CollectionCategory(
            title: L10n.Seed.comicsTitle,
            subtitle: L10n.Seed.comicsSubtitle,
            symbolName: "book.closed.fill",
            template: .comics,
            groups: [
                CollectionGroup(
                    title: L10n.Seed.invincibleTitle,
                    subtitle: L10n.Seed.invincibleSubtitle,
                    items: [
                        CollectibleItem(
                            title: L10n.Seed.invincibleOneTitle,
                            subtitle: L10n.Seed.issueSubtitle,
                            notes: L10n.Seed.sampleNote,
                            readingStatus: .read
                        ),
                        CollectibleItem(
                            title: L10n.Seed.invincibleFourTitle,
                            subtitle: L10n.Seed.wishlistSubtitle,
                            notes: L10n.Seed.missingSampleNote,
                            ownershipStatus: .missing
                        )
                    ]
                )
            ]
        ),
        CollectionCategory(
            title: L10n.Seed.vinylTitle,
            subtitle: L10n.Seed.vinylSubtitle,
            symbolName: "record.circle.fill",
            template: .vinyl,
            groups: [
                CollectionGroup(title: L10n.Seed.rockTitle, subtitle: L10n.Seed.genreSubtitle)
            ]
        ),
        CollectionCategory(
            title: L10n.Seed.gamesTitle,
            subtitle: L10n.Seed.gamesSubtitle,
            symbolName: "gamecontroller.fill",
            template: .games
        ),
        CollectionCategory(
            title: L10n.Seed.booksTitle,
            subtitle: L10n.Seed.booksSubtitle,
            symbolName: "books.vertical.fill",
            template: .books
        )
    ]
}
