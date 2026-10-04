import SwiftUI

struct ItemDetailNotesView: View {
    let notes: String
    let onEdit: () -> Void

    var body: some View {
        Button(action: onEdit) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: notes.isEmpty ? "plus.square.fill" : "note.text")
                    .font(.title3.weight(.black))
                    .foregroundStyle(notes.isEmpty ? ComicTheme.red : ComicTheme.blue)

                VStack(alignment: .leading, spacing: 6) {
                    Text(notes.isEmpty ? L10n.ItemDetail.addNotes : L10n.ItemDetail.notesTitle)
                        .font(.caption.weight(.black))
                        .foregroundStyle(ComicTheme.ink.opacity(0.72))

                    Text(notes.isEmpty ? L10n.ItemDetail.noNotes : notes)
                        .font(ComicTheme.bodyFont)
                        .foregroundStyle(ComicTheme.ink.opacity(notes.isEmpty ? 0.6 : 0.82))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Image(systemName: "pencil")
                    .font(.caption.weight(.black))
                    .foregroundStyle(ComicTheme.ink.opacity(0.65))
            }
            .padding(18)
            .comicPanel(fill: ComicTheme.panel)
        }
        .buttonStyle(.plain)
    }
}
