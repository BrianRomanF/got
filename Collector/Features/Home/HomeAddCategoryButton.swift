import SwiftUI

struct HomeAddCategoryButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.headline.weight(.black))
                .foregroundStyle(ComicTheme.ink)
        }
        .accessibilityLabel(L10n.Home.addCategory)
    }
}
