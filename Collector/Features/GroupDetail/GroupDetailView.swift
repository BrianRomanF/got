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
                        ComicBreadcrumbView(parts: [category.title, group.title])
                        GroupHeaderView(group: group)
                        if category.allowsNestedGroups {
                            GroupChildrenSection(
                                categoryID: categoryID,
                                groups: group.groups,
                                movingGroupID: $controller.movingGroupID
                            ) { movedGroupID, direction in
                                libraryController.moveGroup(
                                    with: movedGroupID,
                                    direction: direction,
                                    inCategory: categoryID,
                                    parentGroupID: groupID
                                )
                            } onAddGroup: {
                                controller.isAddingGroup = true
                            }
                        }
                        if category.allowsGroupItems {
                            GroupIssueCounterView(
                                itemTitle: category.template.itemTitle,
                                ownedCount: controller.ownedCount(from: group.items),
                                totalCount: group.items.count
                            )
                            GroupFolderSearchBar(text: $controller.searchText)
                            GroupItemsSection(
                                categoryID: categoryID,
                                groupID: groupID,
                                itemTitle: category.template.itemTitle,
                                items: controller.filteredItems(from: group.items),
                                displayMode: controller.displayMode,
                                onAddItem: {
                                    controller.isAddingItem = true
                                },
                                onEditItem: { item in
                                    controller.itemToEdit = item
                                },
                                onToggleOwnership: { item in
                                    libraryController.updateItemOwnership(
                                        itemID: item.id,
                                        status: item.ownershipStatus == .owned ? .missing : .owned,
                                        inCategory: categoryID,
                                        groupID: groupID
                                    )
                                },
                                onDeleteItem: { item in
                                    controller.itemToDelete = item
                                }
                            )
                        }
                    }
                    .padding(20)
                }
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        if category.allowsNestedGroups {
                            GroupToolbarButton(systemName: "folder.badge.plus", label: L10n.Detail.addGroup) {
                                controller.isAddingGroup = true
                            }
                        }

                        if category.allowsGroupItems {
                            GroupToolbarButton(systemName: "plus.square.fill", label: L10n.Detail.addItem) {
                                controller.isAddingItem = true
                            }
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
                .sheet(item: $controller.itemToEdit) { item in
                    ItemEditorView(template: category.template, mode: .edit(item)) { updatedItem in
                        libraryController.updateItem(updatedItem, inCategory: categoryID, groupID: groupID)
                        controller.itemToEdit = nil
                    }
                }
                .alert(L10n.ItemDetail.deleteTitle, isPresented: deleteItemAlertBinding) {
                    Button(L10n.Common.cancel, role: .cancel) {
                        controller.itemToDelete = nil
                    }
                    Button(L10n.ItemDetail.delete, role: .destructive) {
                        guard let item = controller.itemToDelete else { return }
                        libraryController.deleteItem(with: item.id, inCategory: categoryID, groupID: groupID)
                        controller.itemToDelete = nil
                    }
                } message: {
                    Text(L10n.ItemDetail.deleteMessage)
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

    private var deleteItemAlertBinding: Binding<Bool> {
        Binding(
            get: { controller.itemToDelete != nil },
            set: { isPresented in
                if !isPresented {
                    controller.itemToDelete = nil
                }
            }
        )
    }
}
