import SwiftUI

struct HomeToolbar: ToolbarContent {
    let onSettings: () -> Void
    let onAddCategory: () -> Void

    var body: some ToolbarContent {
        if #available(iOS 26.0, *) {
            leadingButtons.sharedBackgroundVisibility(.hidden)
            addButton.sharedBackgroundVisibility(.hidden)
        } else {
            leadingButtons
            addButton
        }
    }

    private var leadingButtons: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack(spacing: 12) {
                NavigationLink(value: CollectorRoute.globalSearch) {
                    HomeToolbarIconLabel(symbolName: "magnifyingglass")
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.GlobalSearch.title)

                Button(action: onSettings) {
                    HomeToolbarIconLabel(symbolName: "gearshape.fill")
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.Settings.title)
            }
            .padding(.bottom, 2)
        }
    }

    private var addButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HomeAddCategoryButton(action: onAddCategory)
                .padding(.bottom, 2)
        }
    }
}
