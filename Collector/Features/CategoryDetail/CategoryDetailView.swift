import SwiftUI

struct CategoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var libraryController: CollectionLibraryController
    @EnvironmentObject private var proAccess: ProAccessController
    @StateObject private var controller = CategoryDetailController()
    @State private var isShowingPaywall = false
    @State private var paywallMessage = L10n.Pro.subtitle
    let categoryID: UUID

    var body: some View {
        ZStack {
            HalftoneBackground()

            if let category = libraryController.category(with: categoryID) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        ComicBreadcrumbView(parts: [L10n.Home.title, category.title])
                        CategoryHeaderView(category: category)
                        if category.allowsTopLevelGroups {
                            CategoryGroupSection(
                                category: category,
                                movingGroupID: $controller.movingGroupID
                            ) { groupID, direction in
                                libraryController.moveGroup(with: groupID, direction: direction, inCategory: categoryID)
                            } onAddGroup: {
                                controller.isAddingGroup = true
                            }
                        }

                        if category.allowsTopLevelItems {
                            ItemOptionsPanel(
                                isExpanded: $controller.isOptionsExpanded,
                                ownershipFilter: $controller.ownershipFilter,
                                quickFilter: $controller.quickFilter,
                                sortOption: $controller.sortOption,
                                displayMode: $controller.displayMode,
                                includesBookFilters: category.template == .books
                            )
                            CategoryItemSection(
                                category: category,
                                items: controller.filteredItems(from: category.items),
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
                                        groupID: nil
                                    )
                                },
                                onDeleteItem: { item in
                                    controller.itemToDelete = item
                                }
                            )

                            if controller.isSelectingItems {
                                BulkItemActionBar(
                                    selectedCount: controller.selectedItemIDs.count,
                                    canMove: !libraryController.itemMoveDestinations(inCategory: categoryID).filter { $0.groupID != nil }.isEmpty,
                                    onMarkOwned: {
                                        libraryController.updateItemsOwnership(itemIDs: controller.selectedItemIDs, status: .owned, inCategory: categoryID, groupID: nil)
                                        controller.clearSelection()
                                    },
                                    onMarkMissing: {
                                        libraryController.updateItemsOwnership(itemIDs: controller.selectedItemIDs, status: .missing, inCategory: categoryID, groupID: nil)
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
                        if category.template == .comics {
                            CategoryToolbarButton(systemName: "square.and.arrow.down.fill", label: L10n.ComicVine.importSeriesTitle) {
                                controller.isImportingSeries = true
                            }
                        }

                        if category.allowsTopLevelGroups {
                            CategoryToolbarButton(systemName: "folder.badge.plus", label: category.template.addTopLevelGroupTitle) {
                                controller.isAddingGroup = true
                            }
                        }

                        if category.allowsTopLevelItems {
                            CategoryToolbarButton(
                                systemName: controller.isSelectingItems ? "checkmark.circle.fill" : "checklist",
                                label: controller.isSelectingItems ? L10n.QuickActions.done : L10n.QuickActions.select
                            ) {
                                if controller.isSelectingItems {
                                    controller.clearSelection()
                                } else {
                                    startSelectingItems()
                                }
                            }

                            CategoryToolbarButton(systemName: "plus.square.fill", label: L10n.Detail.addItem) {
                                startAddingItem()
                            }
                        }

                        CategoryToolbarButton(systemName: "trash.fill", label: L10n.CategoryDetail.delete) {
                            controller.isConfirmingDelete = true
                        }
                    }
                }
                .sheet(isPresented: $controller.isAddingGroup) {
                    CategoryNewGroupSheet(
                        navigationTitle: category.template.addTopLevelGroupTitle,
                        titlePlaceholder: category.template.topLevelGroupNamePlaceholder,
                        title: $controller.groupTitle,
                        subtitle: $controller.groupSubtitle,
                        canSave: controller.canSaveGroup()
                    ) {
                        libraryController.addGroup(
                            title: controller.groupTitle,
                            subtitle: controller.groupSubtitle,
                            toCategory: categoryID
                        )
                        controller.resetGroupForm()
                        controller.isAddingGroup = false
                    }
                }
                .sheet(isPresented: $controller.isImportingSeries) {
                    ComicVineSeriesImportSheet { group in
                        libraryController.addGroup(group, toCategory: categoryID)
                        controller.isImportingSeries = false
                    }
                }
                .sheet(isPresented: $controller.isAddingItem) {
                    ItemEditorView(template: category.template) { item in
                        libraryController.addItem(item, toCategory: categoryID)
                        controller.isAddingItem = false
                    }
                }
                .sheet(isPresented: $isShowingPaywall) {
                    ProPaywallView(message: paywallMessage)
                }
                .sheet(isPresented: $controller.isMovingSelectedItems) {
                    ItemMoveDestinationPicker(
                        destinations: libraryController.itemMoveDestinations(inCategory: categoryID),
                        currentGroupID: nil
                    ) { destination in
                        libraryController.moveItems(
                            with: controller.selectedItemIDs,
                            inCategory: categoryID,
                            fromGroupID: nil,
                            toGroupID: destination.groupID
                        )
                        controller.isMovingSelectedItems = false
                        controller.clearSelection()
                    }
                }
                .sheet(item: $controller.itemToEdit) { item in
                    ItemEditorView(template: category.template, mode: .edit(item)) { updatedItem in
                        libraryController.updateItem(updatedItem, inCategory: categoryID, groupID: nil)
                        controller.itemToEdit = nil
                    }
                }
                .alert(L10n.ItemDetail.deleteTitle, isPresented: deleteItemAlertBinding) {
                    Button(L10n.Common.cancel, role: .cancel) {
                        controller.itemToDelete = nil
                    }
                    Button(L10n.ItemDetail.delete, role: .destructive) {
                        guard let item = controller.itemToDelete else { return }
                        libraryController.deleteItem(with: item.id, inCategory: categoryID, groupID: nil)
                        controller.itemToDelete = nil
                    }
                } message: {
                    Text(L10n.ItemDetail.deleteMessage)
                }
                .alert(L10n.QuickActions.deleteSelectedTitle, isPresented: $controller.isConfirmingBulkDelete) {
                    Button(L10n.Common.cancel, role: .cancel) {}
                    Button(L10n.QuickActions.deleteSelected, role: .destructive) {
                        libraryController.deleteItems(with: controller.selectedItemIDs, inCategory: categoryID, groupID: nil)
                        controller.clearSelection()
                    }
                } message: {
                    Text(L10n.QuickActions.deleteSelectedMessage)
                }
                .alert(L10n.CategoryDetail.deleteTitle, isPresented: $controller.isConfirmingDelete) {
                    Button(L10n.Common.cancel, role: .cancel) {}
                    Button(L10n.CategoryDetail.deleteConfirm, role: .destructive) {
                        libraryController.deleteCategory(with: categoryID)
                        dismiss()
                    }
                } message: {
                    Text(L10n.CategoryDetail.deleteMessage)
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
