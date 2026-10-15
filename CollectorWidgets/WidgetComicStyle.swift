import SwiftUI

enum WidgetComicStyle {
    static let paper = Color(red: 0.98, green: 0.94, blue: 0.82)
    static let panel = Color(red: 1.0, green: 0.98, blue: 0.9)
    static let ink = Color(red: 0.08, green: 0.08, blue: 0.09)
    static let red = Color(red: 0.72, green: 0.08, blue: 0.08)
    static let green = Color(red: 0.1, green: 0.62, blue: 0.42)
}

struct WidgetComicBackground: View {
    var body: some View {
        WidgetComicStyle.paper
            .overlay {
                Canvas { context, size in
                    var dots = Path()
                    for y in stride(from: 0.0, to: size.height, by: 28) {
                        for x in stride(from: 0.0, to: size.width, by: 28) {
                            dots.addEllipse(in: CGRect(x: x + 5, y: y + 5, width: 4, height: 4))
                            dots.addEllipse(in: CGRect(x: x + 19, y: y + 19, width: 4, height: 4))
                        }
                    }
                    context.fill(dots, with: .color(WidgetComicStyle.ink.opacity(0.063)))
                }
            }
    }
}
