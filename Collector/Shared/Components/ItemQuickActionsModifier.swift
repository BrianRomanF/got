import SwiftUI

struct ItemQuickActionsModifier: ViewModifier {
    let item: CollectibleItem
    let onEdit: () -> Void
    let onToggleOwnership: () -> Void
    let onDelete: () -> Void

    func body(content: Content) -> some View {
        content
            .contextMenu {
                Button {
                    onEdit()
                } label: {
                    Label(L10n.ItemDetail.edit, systemImage: "pencil")
                }

                Button {
                    onToggleOwnership()
                } label: {
                    Label(toggleTitle, systemImage: item.ownershipStatus == .owned ? "exclamationmark.triangle.fill" : "checkmark.seal.fill")
                }

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label(L10n.ItemDetail.delete, systemImage: "trash.fill")
                }
            }
    }

    private var toggleTitle: String {
        item.ownershipStatus == .owned ? L10n.QuickActions.markMissing : L10n.QuickActions.markOwned
    }
}

extension View {
    func itemQuickActions(
        item: CollectibleItem,
        onEdit: @escaping () -> Void,
        onToggleOwnership: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) -> some View {
        modifier(
            ItemQuickActionsModifier(
                item: item,
                onEdit: onEdit,
                onToggleOwnership: onToggleOwnership,
                onDelete: onDelete
            )
        )
    }
}
