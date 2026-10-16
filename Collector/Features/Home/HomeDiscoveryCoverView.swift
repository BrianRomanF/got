import SwiftUI

struct HomeDiscoveryCoverView: View {
    let suggestion: HomeDiscoverySuggestion
    @State private var localImage: UIImage?

    var body: some View {
        ZStack {
            ComicTheme.paper
            if let localImage {
                Image(uiImage: localImage).resizable().scaledToFit()
            } else if let url = suggestion.item.coverRemoteURL {
                AsyncImage(url: url) { phase in
                    if case .success(let image) = phase {
                        image.resizable().scaledToFit()
                    } else {
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: 62, height: suggestion.template == .vinyl ? 62 : 82)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .overlay(RoundedRectangle(cornerRadius: 5).stroke(ComicTheme.ink, lineWidth: 2))
        .accessibilityHidden(true)
        .task(id: suggestion.item) {
            localImage = WidgetCoverThumbnail.make(from: suggestion.item).flatMap { UIImage(data: $0) }
        }
    }

    private var placeholder: some View {
        Image(systemName: suggestion.template.defaultSymbolName)
            .font(.title2.weight(.black))
            .foregroundStyle(ComicTheme.red)
    }
}
