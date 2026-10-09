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
            ?? []
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
        categories.reduce(CollectionStats(totalItems: 0, ownedItems: 0, missingItems: 0, groups: 0, taggedItems: 0, uniqueTags: 0, readingItems: 0)) { partial, category in
            let categoryStats = stats(for: category)
            return CollectionStats(
                totalItems: partial.totalItems + categoryStats.totalItems,
                ownedItems: partial.ownedItems + categoryStats.ownedItems,
                missingItems: partial.missingItems + categoryStats.missingItems,
                groups: partial.groups + categoryStats.groups,
                taggedItems: partial.taggedItems + categoryStats.taggedItems,
                uniqueTags: allTags(in: categories).count,
                readingItems: partial.readingItems + categoryStats.readingItems
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

    func globalSearchResults(query: String, allowedKinds: Set<GlobalSearchResultKind> = Set(GlobalSearchResultKind.allCases), tag: String? = nil) -> [GlobalSearchResult] {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedTag = tag?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedQuery.isEmpty || !(normalizedTag?.isEmpty ?? true) else { return [] }

        var results: [GlobalSearchResult] = []

        for category in categories {
            if allowedKinds.contains(.category), normalizedTag == nil, matches(normalizedQuery, in: [category.title, category.subtitle]) {
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

            if allowedKinds.contains(.piece) {
                results.append(contentsOf: globalSearchResults(
                    query: normalizedQuery,
                    tag: normalizedTag,
                    items: category.items,
                    categoryID: category.id,
                    categoryTitle: category.title,
                    groupID: nil,
                    path: category.title
                ))
            }

            results.append(contentsOf: globalSearchResults(
                query: normalizedQuery,
                allowedKinds: allowedKinds,
                tag: normalizedTag,
                groups: category.groups,
                categoryID: category.id,
                categoryTitle: category.title,
                path: category.title
            ))
        }

        return Array(results.prefix(60))
    }

    func allTags() -> [String] {
        allTags(in: categories)
    }

    func recentActivity(limit: Int = 20) -> [RecentActivityEntry] {
        let entries = categories
            .flatMap { category in
                recentActivityEntries(in: category)
            }
            .sorted { $0.activityDate > $1.activityDate }

        return entriesOnLatestActivityDay(entries)
            .prefix(limit)
            .map { $0 }
    }

    func recentActivityCategorySummaries() -> [RecentActivityCategorySummary] {
        let latestDate = categories
            .flatMap { recentActivityEntries(in: $0) }
            .map(\.activityDate)
            .max()

        return categories.compactMap { category in
            let sections = recentActivitySections(in: category, matchingLatestDayOf: latestDate)
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
        let latestDate = categories
            .flatMap { recentActivityEntries(in: $0) }
            .map(\.activityDate)
            .max()
        return recentActivitySections(in: category, matchingLatestDayOf: latestDate)
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

    func addItems(_ items: [CollectibleItem], toCategory categoryID: UUID) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else { return }
        categories[categoryIndex].items.append(contentsOf: items)
    }

    func addItem(_ item: CollectibleItem, toGroup groupID: UUID, inCategory categoryID: UUID) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else { return }
        insertItem(item, groupID: groupID, groups: &categories[categoryIndex].groups)
    }

    func addItems(_ items: [CollectibleItem], toGroup groupID: UUID, inCategory categoryID: UUID) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else { return }
        for item in items {
            insertItem(item, groupID: groupID, groups: &categories[categoryIndex].groups)
        }
    }

    func moveItems(with itemIDs: Set<UUID>, inCategory categoryID: UUID, fromGroupID: UUID?, toGroupID: UUID?) {
        guard !itemIDs.isEmpty, fromGroupID != toGroupID else { return }
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else { return }

        let movedItems: [CollectibleItem]
        if let fromGroupID {
            movedItems = extractItems(with: itemIDs, groupID: fromGroupID, groups: &categories[categoryIndex].groups)
        } else {
            var extracted: [CollectibleItem] = []
            categories[categoryIndex].items.removeAll { item in
                if itemIDs.contains(item.id) {
                    extracted.append(item)
                    return true
                }
                return false
            }
            movedItems = extracted
        }

        let updatedItems = movedItems.map { item in
            var updatedItem = item
            updatedItem.updatedAt = .now
            return updatedItem
        }

        if let toGroupID {
            for item in updatedItems {
                insertItem(item, groupID: toGroupID, groups: &categories[categoryIndex].groups)
            }
        } else {
            categories[categoryIndex].items.append(contentsOf: updatedItems)
        }
    }

    func updateItemsOwnership(itemIDs: Set<UUID>, status: ItemOwnershipStatus, inCategory categoryID: UUID, groupID: UUID?) {
        for itemID in itemIDs {
            updateItemOwnership(itemID: itemID, status: status, inCategory: categoryID, groupID: groupID)
        }
    }

    func deleteItems(with itemIDs: Set<UUID>, inCategory categoryID: UUID, groupID: UUID?) {
        for itemID in itemIDs {
            deleteItem(with: itemID, inCategory: categoryID, groupID: groupID)
        }
    }

    func itemMoveDestinations(inCategory categoryID: UUID) -> [ItemMoveDestination] {
        guard let category = category(with: categoryID) else { return [] }
        return [ItemMoveDestination(groupID: nil, title: L10n.RecentActivity.noShelf, subtitle: category.title)]
            + itemMoveDestinations(in: category.groups, path: category.title)
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

    private func itemMoveDestinations(in groups: [CollectionGroup], path: String) -> [ItemMoveDestination] {
        groups.flatMap { group in
            let groupPath = [path, group.title].joined(separator: " > ")
            return [
                ItemMoveDestination(groupID: group.id, title: group.title, subtitle: groupPath)
            ] + itemMoveDestinations(in: group.groups, path: groupPath)
        }
    }

    private func extractItems(with itemIDs: Set<UUID>, groupID: UUID, groups: inout [CollectionGroup]) -> [CollectibleItem] {
        for index in groups.indices {
            if groups[index].id == groupID {
                var extracted: [CollectibleItem] = []
                groups[index].items.removeAll { item in
                    if itemIDs.contains(item.id) {
                        extracted.append(item)
                        return true
                    }
                    return false
                }
                return extracted
            }

            let extracted = extractItems(with: itemIDs, groupID: groupID, groups: &groups[index].groups)
            if !extracted.isEmpty {
                return extracted
            }
        }

        return []
    }

    private func stats(items: [CollectibleItem], groups: [CollectionGroup]) -> CollectionStats {
        let directOwned = items.filter { $0.ownershipStatus == .owned }.count
        let directMissing = items.filter { $0.ownershipStatus == .missing }.count
        let directTags = Set(items.flatMap(\.tags))

        return groups.reduce(
            CollectionStats(
                totalItems: items.count,
                ownedItems: directOwned,
                missingItems: directMissing,
                groups: groups.count,
                taggedItems: items.filter { !$0.tags.isEmpty }.count,
                uniqueTags: directTags.count,
                readingItems: items.filter { $0.readingStatus == .reading }.count
            )
        ) { partial, group in
            let groupStats = stats(items: group.items, groups: group.groups)
            return CollectionStats(
                totalItems: partial.totalItems + groupStats.totalItems,
                ownedItems: partial.ownedItems + groupStats.ownedItems,
                missingItems: partial.missingItems + groupStats.missingItems,
                groups: partial.groups + groupStats.groups,
                taggedItems: partial.taggedItems + groupStats.taggedItems,
                uniqueTags: allTags(in: items, groups: groups).count,
                readingItems: partial.readingItems + groupStats.readingItems
            )
        }
    }

    private func allTags(in categories: [CollectionCategory]) -> [String] {
        let tags = categories.flatMap { category in
            allTags(in: category.items, groups: category.groups)
        }

        return normalizedUniqueTags(tags)
    }

    private func allTags(in items: [CollectibleItem], groups: [CollectionGroup]) -> [String] {
        let directTags = items.flatMap(\.tags)
        let nestedTags = groups.flatMap { group in
            allTags(in: group.items, groups: group.groups)
        }

        return normalizedUniqueTags(directTags + nestedTags)
    }

    private func normalizedUniqueTags(_ tags: [String]) -> [String] {
        var seen = Set<String>()
        return tags.compactMap { tag in
            let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
            let key = trimmed.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            guard !trimmed.isEmpty, !seen.contains(key) else { return nil }
            seen.insert(key)
            return trimmed
        }
        .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
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
        allowedKinds: Set<GlobalSearchResultKind>,
        tag: String?,
        groups: [CollectionGroup],
        categoryID: UUID,
        categoryTitle: String,
        path: String
    ) -> [GlobalSearchResult] {
        groups.flatMap { group in
            let groupPath = [path, group.title].joined(separator: " > ")
            var results: [GlobalSearchResult] = []

            if allowedKinds.contains(.shelf), tag == nil, matches(query, in: [group.title, group.subtitle]) {
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

            if allowedKinds.contains(.piece) {
                results.append(contentsOf: globalSearchResults(
                    query: query,
                    tag: tag,
                    items: group.items,
                    categoryID: categoryID,
                    categoryTitle: categoryTitle,
                    groupID: group.id,
                    path: groupPath
                ))
            }

            results.append(contentsOf: globalSearchResults(
                query: query,
                allowedKinds: allowedKinds,
                tag: tag,
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
        tag: String?,
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
            ] + item.tags + (item.templateDetails?.map(\.value) ?? [])

            let matchesQuery = query.isEmpty || matches(query, in: searchableValues)
            let matchesTag = tag.map { selectedTag in
                item.tags.contains { $0.compare(selectedTag, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame }
            } ?? true

            guard matchesQuery && matchesTag else { return nil }

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

    private func recentActivitySections(in category: CollectionCategory, matchingLatestDayOf latestDate: Date?) -> [RecentActivitySection] {
        var sections: [RecentActivitySection] = []

        let rootEntries = entriesOnLatestActivityDay(category.items
            .map {
                RecentActivityEntry(
                    categoryID: category.id,
                    groupID: nil,
                    item: $0,
                    categoryTitle: category.title,
                    groupTitle: nil
                )
            }
            .sorted { $0.activityDate > $1.activityDate }, latestDate: latestDate)

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
            categoryTitle: category.title,
            matchingLatestDayOf: latestDate
        ))

        return sections.sorted { ($0.latestDate ?? .distantPast) > ($1.latestDate ?? .distantPast) }
    }

    private func recentActivitySections(
        in groups: [CollectionGroup],
        categoryID: UUID,
        categoryTitle: String,
        matchingLatestDayOf latestDate: Date?
    ) -> [RecentActivitySection] {
        groups.flatMap { group in
            var sections: [RecentActivitySection] = []
            let entries = entriesOnLatestActivityDay(group.items
                .map {
                    RecentActivityEntry(
                        categoryID: categoryID,
                        groupID: group.id,
                        item: $0,
                        categoryTitle: categoryTitle,
                        groupTitle: group.title
                    )
                }
                .sorted { $0.activityDate > $1.activityDate }, latestDate: latestDate)

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

            sections.append(contentsOf: recentActivitySections(
                in: group.groups,
                categoryID: categoryID,
                categoryTitle: categoryTitle,
                matchingLatestDayOf: latestDate
            ))
            return sections.sorted { ($0.latestDate ?? .distantPast) > ($1.latestDate ?? .distantPast) }
        }
    }

    private func entriesOnLatestActivityDay(_ entries: [RecentActivityEntry], latestDate: Date? = nil) -> [RecentActivityEntry] {
        guard let latestDate = latestDate ?? entries.map(\.activityDate).max() else { return [] }

        return entries.filter {
            Calendar.autoupdatingCurrent.isDate($0.activityDate, inSameDayAs: latestDate)
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
