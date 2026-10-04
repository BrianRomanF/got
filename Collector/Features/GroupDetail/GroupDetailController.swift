import Foundation

final class GroupDetailController: ObservableObject {
    @Published var isAddingGroup = false
    @Published var isAddingItem = false
    @Published var isConfirmingDelete = false
    @Published var groupTitle = ""
    @Published var groupSubtitle = ""
    @Published var ownershipFilter: ItemOwnershipFilter = .all
    @Published var searchText = ""
    @Published var movingGroupID: UUID?

    func resetGroupForm() {
        groupTitle = ""
        groupSubtitle = ""
    }

    func canSaveGroup() -> Bool {
        !groupTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func filteredItems(from items: [CollectibleItem]) -> [CollectibleItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return items.filter { item in
            ownershipFilter.includes(item) && matchesSearch(item, query: query)
        }
    }

    func ownedCount(from items: [CollectibleItem]) -> Int {
        items.filter { $0.ownershipStatus == .owned }.count
    }

    private func matchesSearch(_ item: CollectibleItem, query: String) -> Bool {
        guard !query.isEmpty else { return true }

        return item.title.lowercased().contains(query)
            || item.subtitle.lowercased().contains(query)
            || item.notes.lowercased().contains(query)
    }
}
