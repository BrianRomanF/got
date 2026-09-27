import SwiftUI

struct DiscogsSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var controller = DiscogsSearchController()
    let initialQuery: String
    let onSelect: (DiscogsSearchResult) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                HalftoneBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        Picker(L10n.Discogs.format, selection: $controller.selectedFormat) {
                            ForEach(DiscogsMediaFormat.allCases) { format in
                                Text(format.title).tag(format)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(12)
                        .comicPanel(fill: ComicTheme.panel)

                        DiscogsSearchField(text: $controller.query) {
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
                                DiscogsSearchResultCell(result: result)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(L10n.Discogs.searchTitle)
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
