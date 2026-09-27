import SwiftUI

struct ComicVineSeriesImportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var controller = ComicVineSeriesImportController()
    let onImport: (CollectionGroup) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                HalftoneBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        ComicVineSeriesSearchField(text: $controller.query) {
                            controller.searchVolumes()
                        }

                        ComicVineSeriesOwnershipPicker(selection: $controller.defaultOwnershipStatus)

                        if controller.isSearching || controller.isImporting {
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

                        if !controller.query.isEmpty, !controller.isSearching, !controller.isImporting, controller.errorMessage == nil, controller.volumes.isEmpty {
                            ComicEmptyStateView(
                                systemName: "magnifyingglass",
                                title: L10n.Empty.searchTitle,
                                message: L10n.Empty.searchMessage
                            )
                        }

                        ForEach(controller.volumes) { volume in
                            Button {
                                Task {
                                    guard let group = await controller.importGroup(from: volume) else { return }
                                    onImport(group)
                                    dismiss()
                                }
                            } label: {
                                ComicVineVolumeResultCell(volume: volume)
                            }
                            .buttonStyle(.plain)
                            .disabled(controller.isImporting)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(L10n.ComicVine.importSeriesTitle)
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
        }
    }
}
