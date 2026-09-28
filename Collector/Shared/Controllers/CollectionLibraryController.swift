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

        if let groupID {
            updateItem(item, groupID: groupID, groups: &categories[categoryIndex].groups)
            return
        }

        guard let itemIndex = categories[categoryIndex].items.firstIndex(where: { $0.id == item.id }) else { return }
        categories[categoryIndex].items[itemIndex] = item
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
        )
    ]
}
