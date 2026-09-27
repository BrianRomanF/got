import SwiftUI

struct GroupNewGroupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var title: String
    @Binding var subtitle: String
    let canSave: Bool
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                HalftoneBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        ComicSheetHeader(
                            title: L10n.Detail.addGroup,
                            subtitle: L10n.Detail.newGroupHint
                        )

                        VStack(spacing: 12) {
                            TextField("", text: $title, prompt: Text(L10n.Detail.groupName).foregroundStyle(ComicTheme.ink.opacity(0.45)))
                                .comicTextField()

                            TextField("", text: $subtitle, prompt: Text(L10n.Detail.groupSubtitle).foregroundStyle(ComicTheme.ink.opacity(0.45)))
                                .comicTextField()
                        }
                        .padding(16)
                        .comicPanel(fill: ComicTheme.panel)

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
