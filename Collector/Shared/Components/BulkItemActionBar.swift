import SwiftUI

struct BulkItemActionBar: View {
    let selectedCount: Int
    let canMove: Bool
    let onMarkOwned: () -> Void
    let onMarkMissing: () -> Void
    let onMove: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(String(format: L10n.QuickActions.selectedCount, selectedCount).uppercased())
                .font(.caption.weight(.black))
                .foregroundStyle(ComicTheme.ink.opacity(0.72))

            HStack(spacing: 8) {
                actionButton(title: L10n.QuickActions.markOwned, systemName: "checkmark.seal.fill", action: onMarkOwned)
                actionButton(title: L10n.QuickActions.markMissing, systemName: "exclamationmark.triangle.fill", action: onMarkMissing)

                if canMove {
                    actionButton(title: L10n.QuickActions.move, systemName: "folder.fill.badge.plus", action: onMove)
                }

                actionButton(title: L10n.QuickActions.deleteSelected, systemName: "trash.fill", action: onDelete)
            }
        }
        .padding(14)
        .comicPanel(fill: ComicTheme.yellow)
    }

    private func actionButton(title: String, systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.headline.weight(.black))
                .foregroundStyle(ComicTheme.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(ComicTheme.ink, lineWidth: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .disabled(selectedCount == 0)
        .opacity(selectedCount == 0 ? 0.45 : 1)
    }
}

struct ItemMoveDestinationPicker: View {
    let destinations: [ItemMoveDestination]
    let currentGroupID: UUID?
    let onSelect: (ItemMoveDestination) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                HalftoneBackground()

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(destinations.filter { $0.groupID != currentGroupID }) { destination in
                            Button {
                                onSelect(destination)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: destination.groupID == nil ? "tray.full.fill" : "folder.fill")
                                        .font(.title3.weight(.black))
                                        .foregroundStyle(ComicTheme.red)
                                        .frame(width: 38)

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(destination.title)
                                            .font(.headline.weight(.black))
                                            .foregroundStyle(ComicTheme.ink)

                                        Text(destination.subtitle)
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(ComicTheme.ink.opacity(0.68))
                                            .lineLimit(2)
                                    }

                                    Spacer(minLength: 0)
                                }
                                .padding(14)
                                .comicPanel(fill: ComicTheme.panel)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(L10n.QuickActions.moveTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
