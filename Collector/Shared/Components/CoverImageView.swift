import SwiftUI
import UIKit

struct CoverImageView: View {
    let title: String
    let ownershipStatus: ItemOwnershipStatus
    let localImageData: Data?
    let localImagePath: String?
    let remoteImageURL: URL?
    let ownedFill: Color
    let placeholderSymbolName: String
    let showsTitle: Bool

    var body: some View {
        ZStack {
            fallbackCover

            if let uiImage = localImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding(6)
            } else if let remoteImageURL {
                AsyncImage(url: remoteImageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(6)
                    case .failure:
                        fallbackCover
                    case .empty:
                        ProgressView()
                    @unknown default:
                        fallbackCover
                    }
                }
            }
        }
        .aspectRatio(0.72, contentMode: .fit)
        .clipped()
        .overlay(
            Rectangle()
                .stroke(
                    ownershipStatus == .owned ? ComicTheme.ink : ComicTheme.ink.opacity(0.55),
                    style: StrokeStyle(lineWidth: 3, dash: ownershipStatus == .owned ? [] : [7, 5])
                )
        )
    }

    private var localImage: UIImage? {
        if let localImageData {
            return UIImage(data: localImageData)
        }

        if let localImagePath {
            return UIImage(contentsOfFile: localImagePath)
        }

        return nil
    }

    private var fallbackCover: some View {
        Rectangle()
            .fill(ownershipStatus == .owned ? ownedFill : ComicTheme.panel.opacity(0.35))
            .overlay {
                VStack(spacing: 12) {
                    Image(systemName: ownershipStatus == .owned ? placeholderSymbolName : "questionmark.square.dashed")
                        .font(.system(size: showsTitle ? 56 : 34, weight: .black))

                    if showsTitle {
                        Text(title.uppercased())
                            .font(.title2.weight(.black))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 22)
                    }
                }
                .foregroundStyle(ownershipStatus == .owned ? ComicTheme.panel : ComicTheme.ink.opacity(0.62))
            }
    }
}
