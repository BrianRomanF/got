import SwiftUI

struct ItemNameInput: View {
    @Binding var text: String

    var body: some View {
        TextField("", text: $text, prompt: Text(L10n.ItemEditor.namePlaceholder).foregroundStyle(ComicTheme.ink.opacity(0.45)))
            .textInputAutocapitalization(.words)
            .comicTextField()
    }
}
