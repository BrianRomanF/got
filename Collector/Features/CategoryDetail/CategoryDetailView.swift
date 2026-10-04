import SwiftUI

struct CategoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var libraryController: CollectionLibraryController
    @StateObject private var controller = CategoryDetailController()
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
                            CategoryItemSection(
                                category: category,
                                items: controller.filteredItems(from: category.items),
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
                                        groupID: nil
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
                            CategoryToolbarButton(systemName: "plus.square.fill", label: L10n.Detail.addItem) {
                                controller.isAddingItem = true
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
