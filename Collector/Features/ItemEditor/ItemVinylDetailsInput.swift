import SwiftUI

struct ItemVinylDetailsInput: View {
    @Binding var mediaCondition: VinylConditionGrade
    @Binding var sleeveCondition: VinylConditionGrade
    @Binding var catalogNumber: String

    private let columns = [
        GridItem(.adaptive(minimum: 84), spacing: 8)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(L10n.VinylDetails.title.uppercased().vintageSafe)
                .font(.caption.weight(.black))
                .foregroundStyle(ComicTheme.ink.opacity(0.75))

            conditionPicker(title: L10n.VinylDetails.mediaCondition, selection: $mediaCondition)
            conditionPicker(title: L10n.VinylDetails.sleeveCondition, selection: $sleeveCondition)

            TextField(
                "",
                text: $catalogNumber,
                prompt: Text(L10n.VinylDetails.catalogNumberPlaceholder).foregroundStyle(ComicTheme.ink.opacity(0.55))
            )
            .comicTextField()
        }
        .padding(16)
        .comicPanel(fill: .white)
    }

    private func conditionPicker(title: String, selection: Binding<VinylConditionGrade>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased().vintageSafe)
                .font(.caption2.weight(.black))
                .foregroundStyle(ComicTheme.ink.opacity(0.68))

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(VinylConditionGrade.allCases) { grade in
                    Button {
                        selection.wrappedValue = grade
                    } label: {
                        Text(grade.title.uppercased().vintageSafe)
                            .font(.caption2.weight(.black))
                            .foregroundStyle(selection.wrappedValue == grade ? ComicTheme.ink : ComicTheme.ink.opacity(0.68))
                            .lineLimit(1)
                            .minimumScaleFactor(0.55)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selection.wrappedValue == grade ? ComicTheme.yellow : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke(ComicTheme.ink, lineWidth: selection.wrappedValue == grade ? 3 : 2)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
