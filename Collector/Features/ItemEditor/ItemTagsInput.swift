import SwiftUI

struct ItemTagsInput: View {
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(L10n.ItemEditor.tags.uppercased(), systemImage: "tag.fill")
                .font(.caption.weight(.black))
                .foregroundStyle(ComicTheme.ink.opacity(0.72))

            TextField(
                "",
                text: $text,
                prompt: Text(L10n.ItemEditor.tagsPlaceholder).foregroundStyle(ComicTheme.ink.opacity(0.48))
            )
            .font(ComicTheme.bodyFont)
            .foregroundStyle(ComicTheme.ink)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .padding(14)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(ComicTheme.ink, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .shadow(color: ComicTheme.ink, radius: 0, x: 3, y: 3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
