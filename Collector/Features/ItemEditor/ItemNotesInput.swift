import SwiftUI

struct ItemNotesInput: View {
    @Binding var text: String

    var body: some View {
        TextField("", text: $text, prompt: Text(L10n.ItemEditor.notesPlaceholder).foregroundStyle(ComicTheme.ink.opacity(0.45)), axis: .vertical)
            .lineLimit(4...8)
            .textInputAutocapitalization(.sentences)
            .comicTextField()
    }
}
