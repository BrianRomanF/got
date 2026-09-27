import SwiftUI

struct ItemSubtitleInput: View {
    @Binding var text: String

    var body: some View {
        TextField("", text: $text, prompt: Text(L10n.ItemEditor.subtitlePlaceholder).foregroundStyle(ComicTheme.ink.opacity(0.45)))
            .textInputAutocapitalization(.sentences)
            .comicTextField()
    }
}
