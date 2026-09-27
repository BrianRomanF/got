import SwiftUI

struct ItemSaveButton: View {
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                Text(L10n.Common.save.uppercased())
            }
            .font(.headline.weight(.black))
            .foregroundStyle(ComicTheme.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isEnabled ? ComicTheme.yellow : Color.gray.opacity(0.25))
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(ComicTheme.ink, lineWidth: 3)
            )
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .shadow(color: isEnabled ? ComicTheme.ink : .clear, radius: 0, x: 5, y: 5)
        }
        .disabled(!isEnabled)
    }
}
