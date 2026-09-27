import SwiftUI

struct ComicVineSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var controller = ComicVineSearchController()
    let initialQuery: String
    let onSelect: (ComicVineIssueSearchResult) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                HalftoneBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        ComicVineSearchField(text: $controller.query) {
                            controller.search()
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
                                ComicVineSearchResultCell(result: result)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(L10n.ComicVine.searchTitle)
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
            .onAppear {
                if controller.query.isEmpty {
                    controller.query = initialQuery
                }
            }
        }
    }
}
