import SwiftUI

struct ComicBreadcrumbView: View {
    let parts: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(Array(parts.enumerated()), id: \.offset) { index, part in
                    Text(part.uppercased().vintageSafe)
                        .font(.caption.weight(.black))
                        .foregroundStyle(index == parts.count - 1 ? ComicTheme.ink : ComicTheme.ink.opacity(0.58))

                    if index < parts.count - 1 {
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.black))
                            .foregroundStyle(ComicTheme.red)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(ComicTheme.ink, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 7))
        }
    }
}
