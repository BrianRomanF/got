import SwiftUI

struct RecentActivityFolderCell: View {
    let section: RecentActivitySection

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: section.groupID == nil ? "tray.full.fill" : "folder.fill")
                .font(.title2.weight(.black))
                .foregroundStyle(section.groupID == nil ? ComicTheme.red : ComicTheme.blue)
                .frame(width: 48, height: 48)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(ComicTheme.ink, lineWidth: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 7))

            VStack(alignment: .leading, spacing: 4) {
                Text(section.title.uppercased().vintageSafe)
                    .font(.headline.weight(.black))
                    .foregroundStyle(ComicTheme.ink)
                    .lineLimit(2)

                Text(String(format: L10n.RecentActivity.count, section.count))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(ComicTheme.ink.opacity(0.7))
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.headline.weight(.black))
                .foregroundStyle(ComicTheme.ink.opacity(0.65))
        }
        .padding(14)
        .comicPanel(fill: ComicTheme.panel)
    }
}
