import SwiftUI

struct ItemDetailNotesEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var notes: String
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                HalftoneBackground()

                VStack(spacing: 16) {
                    ComicSheetHeader(
                        title: L10n.ItemDetail.notesTitle,
                        subtitle: L10n.ItemDetail.notesHint
                    )

                    TextEditor(text: $notes)
                        .font(ComicTheme.bodyFont)
                        .foregroundStyle(ComicTheme.ink)
                        .scrollContentBackground(.hidden)
                        .padding(12)
                        .frame(minHeight: 220)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(ComicTheme.ink, lineWidth: 3)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                        .shadow(color: ComicTheme.ink, radius: 0, x: 5, y: 5)

                    ComicSheetSaveButton(isEnabled: true) {
                        onSave()
                        dismiss()
                    }

                    Spacer(minLength: 0)
                }
                .padding(20)
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
