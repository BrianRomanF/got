import SwiftUI
import UniformTypeIdentifiers

struct HomeSVGIconSelector: View {
    @Binding var svgIconURL: String
    let selectedSVGIconPath: String?
    let onSelectSVGFile: (URL) -> Void

    @State private var isImportingSVG = false

    private var svgContentType: UTType {
        UTType(filenameExtension: "svg") ?? .item
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Home.categorySVGIconTitle.uppercased())
                .font(.caption.weight(.black))
                .foregroundStyle(ComicTheme.red)

            Button {
                isImportingSVG = true
            } label: {
                Label(L10n.Home.categorySVGIconSelectFile, systemImage: "doc.badge.plus")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(ComicTheme.ink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(ComicTheme.yellow)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(ComicTheme.ink, lineWidth: 3)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .shadow(color: ComicTheme.ink, radius: 0, x: 4, y: 4)
            }
            .buttonStyle(.plain)

            if let selectedSVGIconPath {
                Label(URL(fileURLWithPath: selectedSVGIconPath).lastPathComponent, systemImage: "checkmark.circle.fill")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(ComicTheme.green)
            }

            TextField("", text: $svgIconURL, prompt: Text(L10n.Home.categorySVGIconURL).foregroundStyle(ComicTheme.ink.opacity(0.72)))
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .comicTextField()

            Text(L10n.Home.categorySVGIconHint)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(ComicTheme.ink.opacity(0.78))
        }
        .padding(16)
        .comicPanel(fill: ComicTheme.panel)
        .fileImporter(
            isPresented: $isImportingSVG,
            allowedContentTypes: [svgContentType],
            allowsMultipleSelection: false
        ) { result in
            guard case .success(let urls) = result, let url = urls.first else { return }
            onSelectSVGFile(url)
        }
    }
}
