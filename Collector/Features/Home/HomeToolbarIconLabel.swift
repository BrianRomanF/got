import SwiftUI

struct HomeToolbarIconLabel: View {
    let symbolName: String
    var fill: Color = ComicTheme.panel

    var body: some View {
        Image(systemName: symbolName)
            .font(.headline.weight(.black))
            .foregroundStyle(ComicTheme.ink)
            .frame(width: 44, height: 44)
            .background(fill, in: RoundedRectangle(cornerRadius: 7))
            .overlay(RoundedRectangle(cornerRadius: 7).stroke(ComicTheme.ink, lineWidth: 1))
            .shadow(color: ComicTheme.ink, radius: 0, x: 2, y: 2)
            .accessibilityHidden(true)
    }
}
