import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var libraryController: CollectionLibraryController
    @StateObject private var controller = HomeController()
    @State private var isShowingSettings = false
    @State private var categoryToEdit: CollectionCategory?
    @State private var categoryToDelete: CollectionCategory?

    var body: some View {
        NavigationStack {
            ZStack {
                HalftoneBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        HomeHeaderView()
                        HomeDashboardSummaryView(
                            stats: libraryController.libraryStats(),
                            categoryCount: libraryController.categories.count
                        )
                        HomeWishlistButton(missingCount: libraryController.libraryStats().missingItems)
                        HomeCategoryGrid(
                            categories: libraryController.categories,
                            stats: { libraryController.stats(for: $0) },
                            onEdit: { category in
                                controller.prepareForEditing(category)
                                categoryToEdit = category
                            },
                            onDelete: { category in
                                categoryToDelete = category
                            }
                        )
                    }
                    .padding(20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.headline.weight(.black))
                    }
                    .accessibilityLabel(L10n.Settings.title)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HomeAddCategoryButton {
                        controller.resetForm()
                        controller.isAddingCategory = true
                    }
                }
            }
            .sheet(isPresented: $controller.isAddingCategory, onDismiss: {
                controller.resetForm()
            }) {
                HomeNewCategorySheet(
                    title: $controller.categoryTitle,
                    subtitle: $controller.categorySubtitle,
                    svgIconURL: $controller.categorySVGIconURL,
                    selectedTemplate: $controller.selectedTemplate,
                    customContentMode: $controller.customContentMode,
                    navigationTitle: L10n.Home.addCategory,
                    hint: L10n.Home.newCategoryHint,
                    selectedSVGIconPath: controller.selectedSVGIconPath,
                    canSave: controller.canSaveCategory(),
                    onSelectSVGFile: { fileURL in
                        controller.saveSelectedSVGIcon(from: fileURL)
                    },
                    onSave: {
                        Task {
                            let svgIconPath = await controller.savedSVGIconPath()
                            libraryController.addCategory(
                                title: controller.categoryTitle,
                                subtitle: controller.categorySubtitle,
                                template: controller.selectedTemplate,
                                customContentMode: controller.customContentMode,
                                svgIconPath: svgIconPath,
                                svgIconRemoteURL: controller.svgIconRemoteURL
                            )
                            controller.resetForm()
                            controller.isAddingCategory = false
                        }
                    }
                )
            }
            .sheet(item: $categoryToEdit, onDismiss: {
                controller.resetForm()
            }) { category in
                HomeNewCategorySheet(
                    title: $controller.categoryTitle,
                    subtitle: $controller.categorySubtitle,
                    svgIconURL: $controller.categorySVGIconURL,
                    selectedTemplate: $controller.selectedTemplate,
                    customContentMode: $controller.customContentMode,
                    navigationTitle: L10n.Home.editCategory,
                    hint: L10n.Home.editCategoryHint,
                    selectedSVGIconPath: controller.selectedSVGIconPath,
                    canSave: controller.canSaveCategory(),
                    onSelectSVGFile: { fileURL in
                        controller.saveSelectedSVGIcon(from: fileURL)
                    },
                    onSave: {
                        Task {
                            let svgIconPath = await controller.savedSVGIconPath()
                            libraryController.updateCategory(
                                with: category.id,
                                title: controller.categoryTitle,
                                subtitle: controller.categorySubtitle,
                                template: controller.selectedTemplate,
                                customContentMode: controller.customContentMode,
                                svgIconPath: svgIconPath,
                                svgIconRemoteURL: controller.svgIconRemoteURL
                            )
                            controller.resetForm()
                            categoryToEdit = nil
                        }
                    }
                )
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
            .alert(L10n.Home.deleteCategoryTitle, isPresented: deleteAlertBinding, presenting: categoryToDelete) { category in
                Button(L10n.Common.cancel, role: .cancel) {
                    categoryToDelete = nil
                }

                Button(L10n.Home.deleteCategory, role: .destructive) {
                    libraryController.deleteCategory(with: category.id)
                    categoryToDelete = nil
                }
            } message: { category in
                Text(String(format: L10n.Home.deleteCategoryMessage, category.title))
            }
            .navigationDestination(for: CollectorRoute.self) { route in
                switch route {
                case .category(let id):
                    CategoryDetailView(categoryID: id)
                case .group(let categoryID, let groupID):
                    GroupDetailView(categoryID: categoryID, groupID: groupID)
                case .item(let categoryID, let groupID, let itemID):
                    ItemDetailView(categoryID: categoryID, groupID: groupID, itemID: itemID)
                case .wishlist:
                    WishlistView()
                case .wishlistCategory(let id):
                    WishlistCategoryView(categoryID: id)
                case .wishlistSection(let sectionID):
                    WishlistSectionItemsView(sectionID: sectionID)
                }
            }
        }
    }

    private var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { categoryToDelete != nil },
            set: { isPresented in
                if !isPresented {
                    categoryToDelete = nil
                }
            }
        )
    }
}
