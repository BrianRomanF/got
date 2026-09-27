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
                        CategoryHeaderView(category: category)
                        CategoryGroupSection(category: category)

                        if category.template.shouldShowTopLevelItemsWhenEmpty || !category.items.isEmpty {
                            OwnershipFilterControl(selection: $controller.ownershipFilter)
                            CategoryItemSection(category: category, items: controller.filteredItems(from: category.items))
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

                        CategoryToolbarButton(systemName: "folder.badge.plus", label: category.template.addTopLevelGroupTitle) {
                            controller.isAddingGroup = true
                        }

                        if category.template.shouldShowTopLevelItemsWhenEmpty || !category.items.isEmpty {
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
}
