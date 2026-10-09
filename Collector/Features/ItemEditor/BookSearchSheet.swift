import SwiftUI

struct BookSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var controller = BookSearchController()
    @State private var isScanningBarcode = false
    let initialQuery: String
    let autoSearchOnAppear: Bool
    let onSelect: (BookSearchResult) -> Void

    init(initialQuery: String, autoSearchOnAppear: Bool = false, onSelect: @escaping (BookSearchResult) -> Void) {
        self.initialQuery = initialQuery
        self.autoSearchOnAppear = autoSearchOnAppear
        self.onSelect = onSelect
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HalftoneBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        HStack(spacing: 10) {
                            BookSearchField(text: $controller.query) {
                                controller.search()
                            }

                            BookBarcodeScanButton {
                                isScanningBarcode = true
                            }
                        }

                        if controller.isLoading {
                            ProgressView()
                                .padding(24)
                                .comicPanel(fill: ComicTheme.panel)
                        }

                        if let errorMessage = controller.errorMessage {
                            Text(errorMessage)
                                .font(ComicTheme.bodyFont)
                                .foregroundStyle(ComicTheme.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .comicPanel(fill: ComicTheme.panel)
                        }

                        if !controller.query.isEmpty, !controller.isLoading, controller.errorMessage == nil, controller.results.isEmpty {
                            ComicEmptyStateView(
                                systemName: "magnifyingglass",
                                title: L10n.Empty.searchTitle,
                                message: L10n.Empty.searchMessage
                            )
                        }

                        ForEach(controller.results) { result in
                            Button {
                                onSelect(result)
                                dismiss()
                            } label: {
                                BookSearchResultCell(result: result)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(L10n.BookSearch.searchTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ComicTheme.paper, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isScanningBarcode) {
                BookBarcodeScannerView { code in
                    controller.query = code
                    isScanningBarcode = false
                    controller.search()
                }
                .ignoresSafeArea()
            }
            .onAppear {
                if controller.query.isEmpty {
                    controller.query = initialQuery
                }
                if autoSearchOnAppear {
                    controller.search()
                }
            }
        }
    }
}
