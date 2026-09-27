import SwiftUI

struct ReadingBadge: View {
    let status: ReadingStatus

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: status.symbolName)
            Text(status.shortTitle.uppercased())
        }
        .font(.caption2.weight(.black))
        .foregroundStyle(ComicTheme.ink)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(status.tint)
        .overlay(
            Capsule()
                .stroke(ComicTheme.ink, lineWidth: 2)
        )
        .clipShape(Capsule())
    }
}
