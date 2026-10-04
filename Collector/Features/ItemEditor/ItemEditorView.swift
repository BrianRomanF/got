import SwiftUI

struct ItemEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var controller: ItemEditorController
    @State private var isSearchingComicVine = false
    @State private var isSearchingTheGamesDB = false
    @State private var isSearchingBooks = false
    @State private var isSearchingDiscogs = false
    @State private var isSearchingTCGdex = false
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
                            TheGamesDBSearchButton {
                                isSearchingTheGamesDB = true
                            }
                        }
                        if template == .books {
                            BookSearchButton {
                                isSearchingBooks = true
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
                        }
                        ItemTemplateDetailsInput(
                            title: L10n.TemplateDetails.title,
                            fields: template.detailFields,
                            values: $controller.templateDetails
                        )
                        ItemNotesInput(text: $controller.notes)
                        ItemSaveButton(isEnabled: controller.canSaveItem()) {
                            Task {
                                let item = await controller.makeItemAfterPreparingCover(template: template)
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
                TheGamesDBSearchSheet(initialQuery: controller.title) { result in
                    controller.applyTheGamesDBResult(result)
                }
            }
            .sheet(isPresented: $isSearchingBooks) {
                BookSearchSheet(initialQuery: controller.title) { result in
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
