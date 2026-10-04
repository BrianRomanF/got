import SwiftUI

struct ItemDetailTemplateDetailsView: View {
    let title: String
    let fields: [TemplateDetailField]
    let values: [String: String]

    var body: some View {
        let rows = fields.compactMap { field -> (TemplateDetailField, String)? in
            guard let value = values[field.key]?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
                return nil
            }
            return (field, value)
        }

        if !rows.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(title.uppercased().vintageSafe)
                    .font(.caption.weight(.black))
                    .foregroundStyle(ComicTheme.ink.opacity(0.75))

                ForEach(rows, id: \.0.id) { field, value in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(field.title.uppercased().vintageSafe)
                            .font(.caption.weight(.black))
                            .foregroundStyle(ComicTheme.red)

                        Text(value)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(ComicTheme.ink.opacity(0.82))

                        Spacer(minLength: 0)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .comicPanel(fill: ComicTheme.panel)
        }
    }
}
