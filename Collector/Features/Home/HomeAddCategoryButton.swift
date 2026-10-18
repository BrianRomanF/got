import SwiftUI

struct HomeAddCategoryButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HomeToolbarIconLabel(symbolName: "plus", fill: ComicTheme.yellow)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.Home.addCategory)
    }
}
