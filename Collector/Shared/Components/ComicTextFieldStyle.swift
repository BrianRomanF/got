import SwiftUI

struct ComicTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(ComicTheme.bodyFont)
            .foregroundStyle(ComicTheme.ink)
            .tint(ComicTheme.blue)
            .padding(16)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(ComicTheme.ink, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .shadow(color: ComicTheme.ink, radius: 0, x: 4, y: 4)
    }
}

extension View {
    func comicTextField() -> some View {
        modifier(ComicTextFieldStyle())
    }
}
