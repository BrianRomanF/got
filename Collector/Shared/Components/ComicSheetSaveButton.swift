import SwiftUI

struct ComicSheetSaveButton: View {
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                Text(L10n.Common.save.uppercased())
            }
            .font(.headline.weight(.black))
            .foregroundStyle(isEnabled ? ComicTheme.ink : ComicTheme.ink.opacity(0.35))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isEnabled ? ComicTheme.yellow : Color.gray.opacity(0.25))
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(ComicTheme.ink, lineWidth: 3)
            )
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .shadow(color: isEnabled ? ComicTheme.ink : .clear, radius: 0, x: 5, y: 5)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}
