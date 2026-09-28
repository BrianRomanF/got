import SwiftUI

struct HomeCustomContentModePicker: View {
    @Binding var selection: CustomCategoryContentMode

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.CustomMode.title.uppercased())
                .font(.caption.weight(.black))
                .foregroundStyle(ComicTheme.red)

            Text(L10n.CustomMode.hint)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(ComicTheme.ink.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                ForEach(CustomCategoryContentMode.allCases) { mode in
                    Button {
                        selection = mode
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: selection == mode ? "checkmark.square.fill" : "square")
                                .font(.headline.weight(.black))
                                .foregroundStyle(selection == mode ? ComicTheme.red : ComicTheme.ink.opacity(0.7))

                            VStack(alignment: .leading, spacing: 3) {
                                Text(mode.title)
                                    .font(.headline.weight(.black))
                                    .foregroundStyle(ComicTheme.ink)

                                Text(mode.description)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(ComicTheme.ink.opacity(0.72))
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer(minLength: 0)
                        }
                        .padding(12)
                        .background(selection == mode ? ComicTheme.yellow.opacity(0.5) : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(ComicTheme.ink, lineWidth: selection == mode ? 3 : 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .comicPanel(fill: ComicTheme.panel)
    }
}
