import SwiftUI

struct ShelfMoveControls: View {
    let canMoveUp: Bool
    let canMoveDown: Bool
    let onMove: (GroupMoveDirection) -> Void
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            moveButton(systemName: "arrow.up", direction: .up, isEnabled: canMoveUp)
            moveButton(systemName: "arrow.down", direction: .down, isEnabled: canMoveDown)

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.black))
                    .foregroundStyle(ComicTheme.ink)
                    .frame(width: 34, height: 34)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(ComicTheme.ink, lineWidth: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 7))
            }
            .buttonStyle(.plain)
        }
        .padding(8)
        .background(ComicTheme.red)
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(ComicTheme.ink, lineWidth: 3)
        )
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .shadow(color: ComicTheme.ink, radius: 0, x: 4, y: 4)
    }

    private func moveButton(systemName: String, direction: GroupMoveDirection, isEnabled: Bool) -> some View {
        Button {
            onMove(direction)
        } label: {
            Image(systemName: systemName)
                .font(.caption.weight(.black))
                .foregroundStyle(isEnabled ? ComicTheme.ink : ComicTheme.ink.opacity(0.35))
                .frame(width: 34, height: 34)
                .background(isEnabled ? ComicTheme.yellow : ComicTheme.paper)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(ComicTheme.ink, lineWidth: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}
