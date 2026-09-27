import SwiftUI

struct HomeCategoryTemplatePicker: View {
    @Binding var selectedTemplate: CollectionTemplate

    private var templates: [CollectionTemplate] {
        [.comics, .books, .vinyl, .games, .tradingCards, .collectibles, .custom]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Home.categoryType.uppercased())
                .font(.caption.weight(.black))
                .foregroundStyle(ComicTheme.red)

            Text(L10n.Home.categoryTypeHint)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(ComicTheme.ink.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)

            Menu {
                ForEach(templates, id: \.self) { template in
                    Button {
                        selectedTemplate = template
                    } label: {
                        Label(template.creationTitle, systemImage: template.defaultSymbolName)
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: selectedTemplate.defaultSymbolName)
                        .font(.headline.weight(.black))
                        .foregroundStyle(ComicTheme.red)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(selectedTemplate.creationTitle)
                            .font(.headline.weight(.black))
                            .foregroundStyle(ComicTheme.ink)

                        Text(selectedTemplate.creationSubtitle)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(ComicTheme.ink.opacity(0.72))
                            .lineLimit(2)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption.weight(.black))
                        .foregroundStyle(ComicTheme.ink)
                }
                .padding(14)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(ComicTheme.ink, lineWidth: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .shadow(color: ComicTheme.ink, radius: 0, x: 4, y: 4)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .comicPanel(fill: ComicTheme.panel)
    }
}
