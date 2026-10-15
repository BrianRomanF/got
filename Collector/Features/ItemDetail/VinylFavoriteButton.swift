import SwiftUI

struct VinylFavoriteButton: View {
    let isFavorite: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            Label(isFavorite ? L10n.VinylFavorite.selected : L10n.VinylFavorite.select,
                  systemImage: isFavorite ? "star.fill" : "star")
                .font(.caption.weight(.black))
                .foregroundStyle(ComicTheme.ink)
                .padding(.horizontal, 12)
                .frame(minHeight: 44)
                .background(isFavorite ? ComicTheme.yellow : ComicTheme.panel, in: RoundedRectangle(cornerRadius: 7))
                .overlay(RoundedRectangle(cornerRadius: 7).stroke(ComicTheme.ink, lineWidth: 2))
        }
        .buttonStyle(.plain)
        .accessibilityHint(L10n.VinylFavorite.hint)
        .accessibilityAddTraits(isFavorite ? .isSelected : [])
    }
}
