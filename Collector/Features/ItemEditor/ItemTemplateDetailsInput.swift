import SwiftUI

struct ItemTemplateDetailsInput: View {
    let title: String
    let fields: [TemplateDetailField]
    @Binding var values: [String: String]

    var body: some View {
        if !fields.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(title.uppercased().vintageSafe)
                    .font(.caption.weight(.black))
                    .foregroundStyle(ComicTheme.ink.opacity(0.75))

                ForEach(fields) { field in
                    TextField(
                        "",
                        text: binding(for: field.key),
                        prompt: Text(field.placeholder).foregroundStyle(ComicTheme.ink.opacity(0.55))
                    )
                    .comicTextField()
                }
            }
            .padding(16)
            .comicPanel(fill: .white)
        }
    }

    private func binding(for key: String) -> Binding<String> {
        Binding(
            get: { values[key] ?? "" },
            set: { newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty {
                    values.removeValue(forKey: key)
                } else {
                    values[key] = newValue
                }
            }
        )
    }
}
