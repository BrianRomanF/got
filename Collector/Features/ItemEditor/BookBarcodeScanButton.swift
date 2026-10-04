import SwiftUI

struct BookBarcodeScanButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "barcode.viewfinder")
                .font(.headline.weight(.black))
                .foregroundStyle(ComicTheme.ink)
                .frame(width: 52, height: 52)
                .background(ComicTheme.red)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(ComicTheme.ink, lineWidth: 3)
                )
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .shadow(color: ComicTheme.ink, radius: 0, x: 4, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.BookSearch.scanBarcode)
    }
}
