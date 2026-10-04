import Foundation

final class CategoryDetailController: ObservableObject {
    @Published var isAddingGroup = false
    @Published var isAddingItem = false
    @Published var isImportingSeries = false
    @Published var isConfirmingDelete = false
    @Published var itemToEdit: CollectibleItem?
    @Published var itemToDelete: CollectibleItem?
    @Published var groupTitle = ""
    @Published var groupSubtitle = ""
    @Published var ownershipFilter: ItemOwnershipFilter
    @Published var quickFilter: ItemQuickFilter
    @Published var sortOption: ItemSortOption
    @Published var displayMode: ItemDisplayMode
    @Published var movingGroupID: UUID?

    init() {
        ownershipFilter = AppSettings.defaultOwnershipFilter
        quickFilter = AppSettings.defaultQuickFilter
        sortOption = AppSettings.defaultSortOption
        displayMode = AppSettings.defaultDisplayMode
    }

    func resetGroupForm() {
        groupTitle = ""
        groupSubtitle = ""
    }

    func canSaveGroup() -> Bool {
        !groupTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func filteredItems(from items: [CollectibleItem]) -> [CollectibleItem] {
        items
            .filter { ownershipFilter.includes($0) && quickFilter.includes($0) }
            .sorted(using: sortOption)
    }
}
