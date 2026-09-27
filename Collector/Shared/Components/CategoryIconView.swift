import SwiftUI

struct CategoryIconView: View {
    let category: CollectionCategory
    let size: CGFloat
    let symbolSize: CGFloat

    var body: some View {
        ZStack {
            ComicTheme.yellow

            if let svgIconPath = category.svgIconPath {
                SVGIconView(svgPath: svgIconPath)
                    .padding(size * 0.18)
            } else {
                Image(systemName: category.symbolName)
                    .font(.system(size: symbolSize, weight: .black))
                    .foregroundStyle(ComicTheme.ink)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(ComicTheme.ink, lineWidth: 3)
        )
    }
}
