import SwiftUI

struct GroupDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var libraryController: CollectionLibraryController
    @StateObject private var controller = GroupDetailController()
    let categoryID: UUID
    let groupID: UUID

    var body: some View {
        ZStack {
            HalftoneBackground()

            if let group = libraryController.group(with: groupID, in: categoryID),
               let category = libraryController.category(with: categoryID) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        GroupHeaderView(group: group)
                        if !group.groups.isEmpty {
                            GroupChildrenSection(categoryID: categoryID, groups: group.groups)
                        }
                        OwnershipFilterControl(selection: $controller.ownershipFilter)
                        GroupItemsSection(
                            categoryID: categoryID,
                            groupID: groupID,
                            itemTitle: category.template.itemTitle,
                            items: controller.filteredItems(from: group.items)
                        )
                    }
                    .padding(20)
                }
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        GroupToolbarButton(systemName: "folder.badge.plus", label: L10n.Detail.addGroup) {
                            controller.isAddingGroup = true
                        }

                        GroupToolbarButton(systemName: "plus.square.fill", label: L10n.Detail.addItem) {
                            controller.isAddingItem = true
                        }

                        GroupToolbarButton(systemName: "trash.fill", label: L10n.GroupDetail.delete) {
                            controller.isConfirmingDelete = true
                        }
                    }
                }
                .sheet(isPresented: $controller.isAddingGroup) {
                    GroupNewGroupSheet(
                        title: $controller.groupTitle,
                        subtitle: $controller.groupSubtitle,
                        canSave: controller.canSaveGroup()
                    ) {
                        libraryController.addGroup(
                            title: controller.groupTitle,
                            subtitle: controller.groupSubtitle,
                            toParent: groupID,
                            inCategory: categoryID
                        )
                        controller.resetGroupForm()
                        controller.isAddingGroup = false
                    }
                }
                .sheet(isPresented: $controller.isAddingItem) {
                    ItemEditorView(template: category.template) { item in
                        libraryController.addItem(item, toGroup: groupID, inCategory: categoryID)
                        controller.isAddingItem = false
                    }
                }
                .alert(L10n.GroupDetail.deleteTitle, isPresented: $controller.isConfirmingDelete) {
                    Button(L10n.Common.cancel, role: .cancel) {}
                    Button(L10n.GroupDetail.deleteConfirm, role: .destructive) {
                        libraryController.deleteGroup(with: groupID, inCategory: categoryID)
                        dismiss()
                    }
                } message: {
                    Text(L10n.GroupDetail.deleteMessage)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
