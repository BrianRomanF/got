import SwiftUI

struct ItemDetailGameBacklogView: View {
    let status: GameBacklogStatus

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemName)
                .font(.title3.weight(.black))
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.GameBacklogStatus.title.uppercased().vintageSafe)
                    .font(.caption.weight(.black))
                    .foregroundStyle(ComicTheme.ink.opacity(0.75))

                Text(status.title)
                    .font(.title3.weight(.black))
                    .foregroundStyle(ComicTheme.ink)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .comicPanel(fill: ComicTheme.yellow)
    }

    private var systemName: String {
        switch status {
        case .pending:
            "tray.fill"
        case .playing:
            "gamecontroller.fill"
        case .finished:
            "flag.checkered"
        case .completed:
            "star.circle.fill"
        case .abandoned:
            "pause.circle.fill"
        }
    }

    private var color: Color {
        switch status {
        case .pending:
            ComicTheme.blue
        case .playing:
            ComicTheme.red
        case .finished, .completed:
            ComicTheme.green
        case .abandoned:
            ComicTheme.ink.opacity(0.65)
        }
    }
}
