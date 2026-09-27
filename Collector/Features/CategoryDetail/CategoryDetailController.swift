import Foundation

final class CategoryDetailController: ObservableObject {
    @Published var isAddingGroup = false
    @Published var isAddingItem = false
    @Published var isImportingSeries = false
    @Published var isConfirmingDelete = false
    @Published var groupTitle = ""
    @Published var groupSubtitle = ""
    @Published var ownershipFilter: ItemOwnershipFilter = .all

    func resetGroupForm() {
        groupTitle = ""
        groupSubtitle = ""
    }

    func canSaveGroup() -> Bool {
        !groupTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func filteredItems(from items: [CollectibleItem]) -> [CollectibleItem] {
        items.filter { ownershipFilter.includes($0) }
    }
}
