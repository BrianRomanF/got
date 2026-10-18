import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var libraryController: CollectionLibraryController
    @EnvironmentObject private var proAccess: ProAccessController
    @StateObject private var controller = HomeController()
    @State private var isShowingSettings = false
    @State private var isShowingPaywall = false
    @State private var paywallMessage = L10n.Pro.subtitle
    @State private var categoryToEdit: CollectionCategory?
    @State private var categoryToDelete: CollectionCategory?
    @State private var navigationPath: [CollectorRoute] = []
    @State private var readingRequestID = UUID()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                HalftoneBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        HomeHeaderView()

                        if libraryController.categories.isEmpty {
                            HomeFirstRunCard {
                                startAddingCategory()
                            }
                        } else {
                            if libraryController.categories.contains(where: { !$0.allItems.isEmpty }) {
                                HomeDiscoverySectionView()
                            }
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
                            HomeDashboardSummaryView(
                                stats: libraryController.libraryStats(),
                                categoryCount: libraryController.categories.count
                            )
                            HomeRecentActivityButton(count: libraryController.recentActivity(limit: 60).count)
                            HomeWishlistButton(missingCount: libraryController.libraryStats().missingItems)
                        }
                    }
                    .padding(20)
                }
            }
            .toolbar {
                HomeToolbar(
                    onSettings: { isShowingSettings = true },
                    onAddCategory: { startAddingCategory() }
                )
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
            .sheet(isPresented: $isShowingPaywall) {
                ProPaywallView(message: paywallMessage)
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
                case .globalSearch:
                    GlobalSearchView()
                case .recentActivity:
                    RecentActivityView()
                case .recentActivityCategory(let id):
                    RecentActivityCategoryView(categoryID: id)
                case .recentActivitySection(let sectionID):
                    RecentActivitySectionItemsView(sectionID: sectionID)
                case .category(let id):
                    CategoryDetailView(categoryID: id)
                case .group(let categoryID, let groupID):
                    GroupDetailView(categoryID: categoryID, groupID: groupID)
                case .item(let categoryID, let groupID, let itemID):
                    ItemDetailView(categoryID: categoryID, groupID: groupID, itemID: itemID)
                case .bookProgress(let categoryID, let groupID, let itemID):
                    ItemDetailView(categoryID: categoryID, groupID: groupID, itemID: itemID, updateReading: true)
                        .id(readingRequestID)
                case .wishlist:
                    WishlistView()
                case .wishlistCategory(let id):
                    WishlistCategoryView(categoryID: id)
                case .wishlistSection(let sectionID):
                    WishlistSectionItemsView(sectionID: sectionID)
                }
            }
        }
        .onOpenURL { url in
            guard url.scheme == "gotit" else { return }
            if url.host == "comics" {
                openComicWidgetURL(url)
                return
            }
            if url.host == "vinyl" {
                openVinylWidgetURL(url)
                return
            }
            guard url.host == "reading" else { return }
            let rawID = url.pathComponents.dropFirst().first
            let id = rawID.flatMap(UUID.init(uuidString:))
            guard rawID == nil || id != nil else { return }
            guard let book = libraryController.bookLocation(id: id) else {
                if rawID == nil, let category = libraryController.categories.first(where: { $0.template == .books }) {
                    navigationPath = [.category(category.id)]
                }
                return
            }
            guard book.item.ownershipStatus == .owned else { return }
            isShowingSettings = false
            isShowingPaywall = false
            categoryToEdit = nil
            controller.isAddingCategory = false
            readingRequestID = UUID()
            navigationPath = [.bookProgress(categoryID: book.categoryID, groupID: book.groupID, itemID: book.item.id)]
        }
    }

    private func openComicWidgetURL(_ url: URL) {
        let parts = Array(url.pathComponents.dropFirst())
        let route: CollectorRoute
        if parts.isEmpty, let category = libraryController.categories.first(where: { $0.template == .comics }) {
            route = .category(category.id)
        } else if parts.count == 2,
                  let categoryID = UUID(uuidString: parts[0]),
                  let groupID = UUID(uuidString: parts[1]),
                  libraryController.category(with: categoryID)?.template == .comics,
                  libraryController.group(with: groupID, in: categoryID) != nil {
            route = .group(categoryID: categoryID, groupID: groupID)
        } else {
            return
        }
        isShowingSettings = false
        isShowingPaywall = false
        categoryToEdit = nil
        controller.isAddingCategory = false
        navigationPath = [route]
    }

    private func openVinylWidgetURL(_ url: URL) {
        let parts = Array(url.pathComponents.dropFirst())
        let route: CollectorRoute
        if parts.isEmpty, let category = libraryController.categories.first(where: { $0.template == .vinyl }) {
            route = .category(category.id)
        } else if parts.count == 1, let itemID = UUID(uuidString: parts[0]),
                  let album = VinylFavoriteSelection.locations(in: libraryController.categories).first(where: { $0.item.id == itemID }) {
            route = .item(categoryID: album.categoryID, groupID: album.groupID, itemID: album.item.id)
        } else {
            return
        }
        isShowingSettings = false
        isShowingPaywall = false
        categoryToEdit = nil
        controller.isAddingCategory = false
        navigationPath = [route]
    }

    private func startAddingCategory() {
        guard proAccess.canCreateCategory(currentCount: libraryController.categories.count) else {
            paywallMessage = L10n.Pro.categoryLimitMessage
            isShowingPaywall = true
            return
        }

        controller.resetForm()
        controller.isAddingCategory = true
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

private struct HomeFirstRunCard: View {
    let onCreateCollection: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(L10n.Home.firstRunTitle.uppercased().vintageSafe)
                    .font(.title3.weight(.black))
                    .foregroundStyle(ComicTheme.ink)

                Text(L10n.Home.firstRunMessage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(ComicTheme.ink.opacity(0.76))
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 10) {
                HomeFirstRunStep(
                    systemName: "square.grid.2x2.fill",
                    title: L10n.Home.firstRunStepCollectionTitle,
                    description: L10n.Home.firstRunStepCollectionBody
                )
                HomeFirstRunStep(
                    systemName: "plus.rectangle.on.folder.fill",
                    title: L10n.Home.firstRunStepPieceTitle,
                    description: L10n.Home.firstRunStepPieceBody
                )
                HomeFirstRunStep(
                    systemName: "externaldrive.fill",
                    title: L10n.Home.firstRunStepBackupTitle,
                    description: L10n.Home.firstRunStepBackupBody
                )
            }

            Button(action: onCreateCollection) {
                Label(L10n.Home.firstRunPrimaryAction.uppercased(), systemImage: "plus")
                    .font(.caption.weight(.black))
                    .foregroundStyle(ComicTheme.ink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(ComicTheme.yellow)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(ComicTheme.ink, lineWidth: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 7))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .comicPanel(fill: ComicTheme.panel)
    }
}

private struct HomeFirstRunStep: View {
    let systemName: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemName)
                .font(.headline.weight(.black))
                .foregroundStyle(ComicTheme.red)
                .frame(width: 26)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(ComicTheme.ink)

                Text(description)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(ComicTheme.ink.opacity(0.68))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(ComicTheme.ink, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}
