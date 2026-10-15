import SwiftUI

struct ItemEditorView: View {
    @EnvironmentObject private var library: CollectionLibraryController
    @Environment(\.dismiss) private var dismiss
    @StateObject private var controller: ItemEditorController
    @State private var isSearchingComicVine = false
    @State private var isSearchingTheGamesDB = false
    @State private var isSearchingBooks = false
    @State private var isSearchingDiscogs = false
    @State private var isSearchingTCGdex = false
    @State private var isScanningSearchCode = false
    @State private var shouldAutoSearchBooks = false
    @State private var shouldAutoSearchGames = false
    let template: CollectionTemplate
    let mode: Mode
    let onSave: (CollectibleItem) -> Void

    enum Mode {
        case create
        case edit(CollectibleItem)

        var title: String {
            switch self {
            case .create:
                L10n.ItemEditor.newItem
            case .edit:
                L10n.ItemEditor.editItem
            }
        }
    }

    init(template: CollectionTemplate = .custom, mode: Mode = .create, onSave: @escaping (CollectibleItem) -> Void) {
        self.template = template
        self.mode = mode
        self.onSave = onSave

        switch mode {
        case .create:
            _controller = StateObject(wrappedValue: ItemEditorController())
        case .edit(let item):
            _controller = StateObject(wrappedValue: ItemEditorController(item: item))
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HalftoneBackground()

                ScrollView {
                    VStack(spacing: 18) {
                        ItemCoverSelector(
                            coverImageData: $controller.coverImageData,
                            coverURLString: $controller.coverURLString
                        )
                        if template == .comics {
                            ComicVineSearchButton {
                                isSearchingComicVine = true
                            }
                        }
                        if template == .games {
                            HStack(spacing: 10) {
                                TheGamesDBSearchButton {
                                    shouldAutoSearchGames = false
                                    isSearchingTheGamesDB = true
                                }

                                BookBarcodeScanButton {
                                    isScanningSearchCode = true
                                }
                            }
                        }
                        if template == .books {
                            HStack(spacing: 10) {
                                BookSearchButton {
                                    shouldAutoSearchBooks = false
                                    isSearchingBooks = true
                                }

                                BookBarcodeScanButton {
                                    isScanningSearchCode = true
                                }
                            }
                        }
                        if template == .vinyl {
                            DiscogsSearchButton {
                                isSearchingDiscogs = true
                            }
                        }
                        if template == .tradingCards {
                            TCGdexSearchButton {
                                isSearchingTCGdex = true
                            }
                        }
                        ItemNameInput(text: $controller.title)
                        ItemSubtitleInput(text: $controller.subtitle)
                        ItemOwnershipInput(selection: $controller.ownershipStatus)
                        if template.supportsReadingStatus {
                            ItemReadingInput(selection: $controller.readingStatus)
                        }
                        if template == .books {
                            ItemBookDetailsInput(
                                rating: $controller.bookRating,
                                protagonist: $controller.bookProtagonist,
                                series: $controller.bookSeries,
                                edition: $controller.bookEdition,
                                format: $controller.bookFormat
                            )
                            ItemBookProgressInput(
                                currentPage: $controller.bookCurrentPage,
                                totalPages: $controller.bookTotalPages,
                                hasStartedAt: $controller.hasBookStartedAt,
                                startedAt: $controller.bookStartedAt,
                                hasFinishedAt: $controller.hasBookFinishedAt,
                                finishedAt: $controller.bookFinishedAt
                            )
                        }
                        if template == .games {
                            ItemGameBacklogInput(selection: $controller.gameBacklogStatus)
                        }
                        if template == .vinyl {
                            ItemVinylDetailsInput(
                                mediaCondition: $controller.vinylMediaCondition,
                                sleeveCondition: $controller.vinylSleeveCondition,
                                catalogNumber: $controller.vinylCatalogNumber
                            )
                        }
                        ItemTemplateDetailsInput(
                            title: L10n.TemplateDetails.title,
                            fields: template.detailFields,
                            values: $controller.templateDetails
                        )
                        ItemLocationInput(text: $controller.physicalLocation)
                        ItemTagsInput(text: $controller.tagsText)
                        ItemNotesInput(text: $controller.notes)
                        if template == .books && !library.canTrackReading(controller.makeItem(template: template)) {
                            Text(L10n.BookReading.limit)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(ComicTheme.red)
                        }
                        ItemSaveButton(isEnabled: controller.canSaveItem() && (template != .books || library.canTrackReading(controller.makeItem(template: template)))) {
                            Task {
                                let item = await controller.makeItemAfterPreparingCover(template: template)
                                guard template != .books || library.canTrackReading(item) else { return }
                                onSave(item)
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ComicTheme.paper, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .sheet(isPresented: $isSearchingComicVine) {
                ComicVineSearchSheet(initialQuery: controller.title) { result in
                    controller.applyComicVineResult(result)
                }
            }
            .sheet(isPresented: $isSearchingTheGamesDB) {
                TheGamesDBSearchSheet(initialQuery: controller.title, autoSearchOnAppear: shouldAutoSearchGames) { result in
                    controller.applyTheGamesDBResult(result)
                }
            }
            .sheet(isPresented: $isSearchingBooks) {
                BookSearchSheet(initialQuery: controller.title, autoSearchOnAppear: shouldAutoSearchBooks) { result in
                    controller.applyBookSearchResult(result)
                }
            }
            .sheet(isPresented: $isSearchingDiscogs) {
                DiscogsSearchSheet(initialQuery: controller.title) { result in
                    controller.applyDiscogsResult(result)
                }
            }
            .sheet(isPresented: $isSearchingTCGdex) {
                TCGdexSearchSheet(initialQuery: controller.title) { result in
                    controller.applyTCGdexResult(result)
                }
            }
            .sheet(isPresented: $isScanningSearchCode) {
                BookBarcodeScannerView { code in
                    controller.title = code
                    isScanningSearchCode = false

                    if template == .books {
                        shouldAutoSearchBooks = true
                        isSearchingBooks = true
                    } else if template == .games {
                        shouldAutoSearchGames = true
                        isSearchingTheGamesDB = true
                    }
                }
                .ignoresSafeArea()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}
