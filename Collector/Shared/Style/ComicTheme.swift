import SwiftUI
import UIKit

enum ComicTheme {
    static let paper = Color(red: 0.98, green: 0.94, blue: 0.82)
    static let ink = Color(red: 0.08, green: 0.08, blue: 0.09)
    static let panel = Color(red: 1.0, green: 0.98, blue: 0.9)
    static let yellow = Color(red: 1.0, green: 0.82, blue: 0.16)
    static let red = Color(red: 0.93, green: 0.16, blue: 0.16)
    static let blue = Color(red: 0.1, green: 0.56, blue: 0.94)
    static let green = Color(red: 0.1, green: 0.62, blue: 0.42)

    static let brandFontName = "VintageOne"
    static let displayFont = Font.custom(brandFontName, size: 38, relativeTo: .largeTitle)
    static let titleFont = Font.custom(brandFontName, size: 26, relativeTo: .title2)
    static let bodyFont = Font.system(.body, design: .rounded).weight(.semibold)

    static let halftoneTile: UIImage = {
        let tileSize = CGSize(width: 28, height: 28)
        let renderer = UIGraphicsImageRenderer(size: tileSize)

        return renderer.image { context in
            UIColor.clear.setFill()
            context.fill(CGRect(origin: .zero, size: tileSize))

            UIColor.black.withAlphaComponent(0.09).setFill()

            let dotSize: CGFloat = 4
            let firstDot = CGRect(x: 5, y: 5, width: dotSize, height: dotSize)
            let secondDot = CGRect(x: 19, y: 19, width: dotSize, height: dotSize)

            UIBezierPath(ovalIn: firstDot).fill()
            UIBezierPath(ovalIn: secondDot).fill()
        }
    }()
}

struct ComicPanelModifier: ViewModifier {
    let fill: Color

    func body(content: Content) -> some View {
        content
            .background(fill)
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(ComicTheme.ink, lineWidth: 3)
            )
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .shadow(color: ComicTheme.ink, radius: 0, x: 5, y: 5)
    }
}

extension View {
    func comicPanel(fill: Color = ComicTheme.panel) -> some View {
        modifier(ComicPanelModifier(fill: fill))
    }
}

struct HalftoneBackground: View {
    var body: some View {
        ComicTheme.paper
            .ignoresSafeArea()
            .overlay {
                Image(uiImage: ComicTheme.halftoneTile)
                    .resizable(resizingMode: .tile)
                    .opacity(0.7)
                    .blendMode(.multiply)
                    .ignoresSafeArea()
            }
    }
}
