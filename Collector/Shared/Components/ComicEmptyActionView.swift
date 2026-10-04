import SwiftUI

struct ComicEmptyActionView: View {
    let systemName: String
    let title: String
    let message: String
    let actionTitle: String
    let actionSystemName: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ComicEmptyStateView(systemName: systemName, title: title, message: message)

            Button(action: action) {
                Label(actionTitle.uppercased().vintageSafe, systemImage: actionSystemName)
                    .font(.caption.weight(.black))
                    .foregroundStyle(ComicTheme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 12)
                    .background(ComicTheme.yellow)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(ComicTheme.ink, lineWidth: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .shadow(color: ComicTheme.ink, radius: 0, x: 3, y: 3)
            }
            .buttonStyle(.plain)
        }
    }
}
