import SwiftUI

struct WidgetCoverThumbnailView: View {
    let data: Data?
    let width: CGFloat
    let height: CGFloat
    var fallbackSymbolName = "book.closed.fill"

    var body: some View {
        ZStack {
            WidgetComicStyle.panel
            if let data, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: fallbackSymbolName)
                    .font(.system(size: 26, weight: .black))
                    .foregroundStyle(WidgetComicStyle.red)
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .overlay(RoundedRectangle(cornerRadius: 5).stroke(WidgetComicStyle.ink, lineWidth: 2))
        .accessibilityHidden(true)
    }
}
