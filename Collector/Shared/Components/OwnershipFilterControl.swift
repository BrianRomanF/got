import SwiftUI

struct OwnershipFilterControl: View {
    @Binding var selection: ItemOwnershipFilter

    var body: some View {
        ComicSegmentedControl(
            options: ItemOwnershipFilter.allCases,
            selection: $selection,
            title: { $0.title }
        )
    }
}
