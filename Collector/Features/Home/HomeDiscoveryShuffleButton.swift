import SwiftUI

struct HomeDiscoveryShuffleButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "shuffle")
                .font(.headline.weight(.black))
                .foregroundStyle(ComicTheme.ink)
                .frame(width: 44, height: 44)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 7))
                .overlay(RoundedRectangle(cornerRadius: 7).stroke(ComicTheme.ink, lineWidth: 2))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.HomeDiscovery.another)
    }
}
