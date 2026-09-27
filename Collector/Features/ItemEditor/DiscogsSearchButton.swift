import SwiftUI

struct DiscogsSearchButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "record.circle.fill")
                Text(L10n.Discogs.searchTitle.uppercased())
            }
            .font(.headline.weight(.black))
            .foregroundStyle(ComicTheme.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(ComicTheme.yellow)
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(ComicTheme.ink, lineWidth: 3)
            )
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .shadow(color: ComicTheme.ink, radius: 0, x: 5, y: 5)
        }
        .buttonStyle(.plain)
    }
}
