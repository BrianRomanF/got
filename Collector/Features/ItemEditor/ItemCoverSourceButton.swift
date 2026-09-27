import SwiftUI

struct ItemCoverSourceButton: View {
    let systemName: String
    let title: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: systemName)
                .font(.headline.weight(.black))

            Text(title.uppercased())
                .font(.caption2.weight(.black))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .foregroundStyle(ComicTheme.ink)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(ComicTheme.yellow)
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(ComicTheme.ink, lineWidth: 3)
        )
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .shadow(color: ComicTheme.ink, radius: 0, x: 4, y: 4)
    }
}
