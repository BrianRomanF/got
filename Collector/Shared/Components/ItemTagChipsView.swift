import SwiftUI

struct ItemTagChipsView: View {
    let tags: [String]
    var limit = 3

    private var visibleTags: [String] {
        Array(tags.prefix(limit))
    }

    var body: some View {
        if !visibleTags.isEmpty {
            HStack(spacing: 6) {
                ForEach(visibleTags, id: \.self) { tag in
                    Text(tag.uppercased())
                        .font(.caption2.weight(.black))
                        .foregroundStyle(ComicTheme.ink.opacity(0.76))
                        .lineLimit(1)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 7)
                        .background(ComicTheme.yellow.opacity(0.55))
                        .overlay(
                            Capsule()
                                .stroke(ComicTheme.ink.opacity(0.55), lineWidth: 1)
                        )
                        .clipShape(Capsule())
                }
            }
        }
    }
}
