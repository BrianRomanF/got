import SwiftUI

struct HomeNewCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var title: String
    @Binding var subtitle: String
    @Binding var svgIconURL: String
    @Binding var selectedTemplate: CollectionTemplate
    @Binding var customContentMode: CustomCategoryContentMode
    let navigationTitle: String
    let hint: String
    let selectedSVGIconPath: String?
    let canSave: Bool
    let onSelectSVGFile: (URL) -> Void
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                HalftoneBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        ComicSheetHeader(
                            title: navigationTitle,
                            subtitle: hint
                        )

                        VStack(spacing: 12) {
                            TextField("", text: $title, prompt: Text(L10n.Home.categoryName).foregroundStyle(ComicTheme.ink.opacity(0.72)))
                                .comicTextField()

                            TextField("", text: $subtitle, prompt: Text(L10n.Home.categorySubtitle).foregroundStyle(ComicTheme.ink.opacity(0.72)))
                                .comicTextField()
                        }
                        .padding(16)
                        .comicPanel(fill: ComicTheme.panel)

                        HomeCategoryTemplatePicker(selectedTemplate: $selectedTemplate)

                        if selectedTemplate == .custom {
                            HomeCustomContentModePicker(selection: $customContentMode)
                        }

                        HomeSVGIconSelector(
                            svgIconURL: $svgIconURL,
                            selectedSVGIconPath: selectedSVGIconPath,
                            onSelectSVGFile: onSelectSVGFile
                        )

                        ComicSheetSaveButton(isEnabled: canSave, action: onSave)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("")
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
