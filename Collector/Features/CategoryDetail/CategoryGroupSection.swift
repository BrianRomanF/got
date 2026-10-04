import SwiftUI
import UIKit

struct CategoryGroupSection: View {
    let category: CollectionCategory
    @Binding var movingGroupID: UUID?
    let onMoveGroup: (UUID, GroupMoveDirection) -> Void
    let onAddGroup: () -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.template.topLevelGroupTitle.uppercased().vintageSafe)
                .font(ComicTheme.titleFont)
                .foregroundStyle(ComicTheme.ink)

            if category.groups.isEmpty {
                ComicEmptyActionView(
                    systemName: "tray.full.fill",
                    title: L10n.Empty.shelvesTitle,
                    message: L10n.Empty.shelvesMessage,
                    actionTitle: category.template.addTopLevelGroupTitle,
                    actionSystemName: "folder.badge.plus",
                    action: onAddGroup
                )
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Array(category.groups.enumerated()), id: \.element.id) { index, group in
                        ZStack(alignment: .topTrailing) {
                            NavigationLink(value: CollectorRoute.group(categoryID: category.id, groupID: group.id)) {
                                CategoryGroupCell(group: group)
                            }
                            .buttonStyle(.plain)
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 0.45)
                                    .onEnded { _ in
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        movingGroupID = group.id
                                    }
                            )

                            if movingGroupID == group.id {
                                ShelfMoveControls(
                                    canMoveUp: index > 0,
                                    canMoveDown: index < category.groups.count - 1,
                                    onMove: { direction in onMoveGroup(group.id, direction) },
                                    onClose: { movingGroupID = nil }
                                )
                                .padding(8)
                                .zIndex(2)
                            }
                        }
                    }
                }
            }
        }
    }
}
