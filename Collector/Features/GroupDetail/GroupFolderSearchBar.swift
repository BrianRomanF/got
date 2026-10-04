import SwiftUI

struct GroupFolderSearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.headline.weight(.black))
                .foregroundStyle(ComicTheme.red)

            TextField("", text: $text, prompt: Text(L10n.GroupDetail.searchPlaceholder).foregroundStyle(ComicTheme.ink.opacity(0.55)))
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .font(.headline.weight(.bold))
                .foregroundStyle(ComicTheme.ink)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.headline.weight(.black))
                        .foregroundStyle(ComicTheme.ink.opacity(0.75))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(ComicTheme.ink, lineWidth: 3)
        )
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .shadow(color: ComicTheme.ink, radius: 0, x: 5, y: 5)
    }
}
