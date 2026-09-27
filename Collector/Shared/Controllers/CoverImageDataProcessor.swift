import UIKit

enum CoverImageDataProcessor {
    static let defaultMaxDimension: CGFloat = 900
    static let defaultMaxBytes = 420_000

    static func optimizedJPEGData(
        from image: UIImage,
        maxDimension: CGFloat = defaultMaxDimension,
        maxBytes: Int = defaultMaxBytes
    ) -> Data? {
        let size = image.size
        let longestSide = max(size.width, size.height)
        let scale = min(1, maxDimension / longestSide)
        let targetSize = CGSize(
            width: max(1, floor(size.width * scale)),
            height: max(1, floor(size.height * scale))
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let resizedImage = renderer.image { _ in
            UIColor.white.setFill()
            UIRectFill(CGRect(origin: .zero, size: targetSize))
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        return compressedJPEGData(from: resizedImage, maxBytes: maxBytes)
    }

    static func optimizedJPEGData(
        from data: Data,
        maxDimension: CGFloat = defaultMaxDimension,
        maxBytes: Int = defaultMaxBytes
    ) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        return optimizedJPEGData(from: image, maxDimension: maxDimension, maxBytes: maxBytes)
    }

    private static func compressedJPEGData(from image: UIImage, maxBytes: Int) -> Data? {
        var quality: CGFloat = 0.72
        var data = image.jpegData(compressionQuality: quality)

        while let currentData = data, currentData.count > maxBytes, quality > 0.42 {
            quality -= 0.08
            data = image.jpegData(compressionQuality: quality)
        }

        return data
    }
}
