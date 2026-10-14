import SwiftUI

struct ItemGameBacklogInput: View {
    @Binding var selection: GameBacklogStatus

    private let columns = [
        GridItem(.adaptive(minimum: 118), spacing: 8)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.GameBacklogStatus.title.uppercased().vintageSafe)
                .font(.caption.weight(.black))
                .foregroundStyle(ComicTheme.ink.opacity(0.75))

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(GameBacklogStatus.allCases) { status in
                    Button {
                        selection = status
                    } label: {
                        Text(status.title.uppercased().vintageSafe)
                            .font(.caption.weight(.black))
                            .foregroundStyle(selection == status ? ComicTheme.ink : ComicTheme.ink.opacity(0.68))
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selection == status ? ComicTheme.yellow : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke(ComicTheme.ink, lineWidth: selection == status ? 3 : 2)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                            .shadow(
                                color: selection == status ? ComicTheme.ink : .clear,
                                radius: 0,
                                x: 3,
                                y: 3
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .comicPanel(fill: .white)
    }
}
