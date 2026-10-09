import SwiftUI

struct GroupDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var libraryController: CollectionLibraryController
    @EnvironmentObject private var proAccess: ProAccessController
    @StateObject private var controller = GroupDetailController()
    @State private var isShowingPaywall = false
    @State private var paywallMessage = L10n.Pro.subtitle
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
                            ItemOptionsPanel(
                                isExpanded: $controller.isOptionsExpanded,
                                ownershipFilter: $controller.ownershipFilter,
                                quickFilter: $controller.quickFilter,
                                sortOption: $controller.sortOption,
                                displayMode: $controller.displayMode,
                                includesBookFilters: category.template == .books
                            )
                            GroupItemsSection(
                                categoryID: categoryID,
                                groupID: groupID,
                                itemTitle: category.template.itemTitle,
                                items: controller.filteredItems(from: group.items),
                                displayMode: controller.displayMode,
                                isSelecting: controller.isSelectingItems,
                                selectedItemIDs: controller.selectedItemIDs,
                                onAddItem: {
                                    startAddingItem()
                                },
                                onToggleSelected: { item in
                                    controller.toggleSelection(for: item)
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

                            if controller.isSelectingItems {
                                BulkItemActionBar(
                                    selectedCount: controller.selectedItemIDs.count,
                                    canMove: libraryController.itemMoveDestinations(inCategory: categoryID).count > 1,
                                    onMarkOwned: {
                                        libraryController.updateItemsOwnership(itemIDs: controller.selectedItemIDs, status: .owned, inCategory: categoryID, groupID: groupID)
                                        controller.clearSelection()
                                    },
                                    onMarkMissing: {
                                        libraryController.updateItemsOwnership(itemIDs: controller.selectedItemIDs, status: .missing, inCategory: categoryID, groupID: groupID)
                                        controller.clearSelection()
                                    },
                                    onMove: {
                                        controller.isMovingSelectedItems = true
                                    },
                                    onDelete: {
                                        controller.isConfirmingBulkDelete = true
                                    }
                                )
                            }
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
                            GroupToolbarButton(
                                systemName: controller.isSelectingItems ? "checkmark.circle.fill" : "checklist",
                                label: controller.isSelectingItems ? L10n.QuickActions.done : L10n.QuickActions.select
                            ) {
                                if controller.isSelectingItems {
                                    controller.clearSelection()
                                } else {
                                    startSelectingItems()
                                }
                            }

                            GroupToolbarButton(systemName: "plus.square.fill", label: L10n.Detail.addItem) {
                                startAddingItem()
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
                .sheet(isPresented: $isShowingPaywall) {
                    ProPaywallView(message: paywallMessage)
                }
                .sheet(isPresented: $controller.isMovingSelectedItems) {
                    ItemMoveDestinationPicker(
                        destinations: libraryController.itemMoveDestinations(inCategory: categoryID),
                        currentGroupID: groupID
                    ) { destination in
                        libraryController.moveItems(
                            with: controller.selectedItemIDs,
                            inCategory: categoryID,
                            fromGroupID: groupID,
                            toGroupID: destination.groupID
                        )
                        controller.isMovingSelectedItems = false
                        controller.clearSelection()
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
                .alert(L10n.QuickActions.deleteSelectedTitle, isPresented: $controller.isConfirmingBulkDelete) {
                    Button(L10n.Common.cancel, role: .cancel) {}
                    Button(L10n.QuickActions.deleteSelected, role: .destructive) {
                        libraryController.deleteItems(with: controller.selectedItemIDs, inCategory: categoryID, groupID: groupID)
                        controller.clearSelection()
                    }
                } message: {
                    Text(L10n.QuickActions.deleteSelectedMessage)
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

    private func startAddingItem() {
        guard proAccess.canAddItems(currentTotal: libraryController.libraryStats().totalItems) else {
            paywallMessage = L10n.Pro.itemLimitMessage
            isShowingPaywall = true
            return
        }

        controller.isAddingItem = true
    }

    private func startSelectingItems() {
        guard proAccess.isProUnlocked else {
            paywallMessage = L10n.Pro.featureLimitMessage
            isShowingPaywall = true
            return
        }

        controller.isSelectingItems = true
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
