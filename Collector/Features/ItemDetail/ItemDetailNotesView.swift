import SwiftUI

struct ItemDetailNotesView: View {
    let notes: String

    var body: some View {
        Text(notes.isEmpty ? L10n.ItemDetail.noNotes : notes)
            .font(ComicTheme.bodyFont)
            .foregroundStyle(ComicTheme.ink.opacity(notes.isEmpty ? 0.55 : 0.82))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .comicPanel(fill: ComicTheme.panel)
    }
}
