import Foundation
import ImageIO
import UIKit

enum WidgetCoverThumbnail {
    static func make(from item: CollectibleItem?, applicationSupportURL: URL? = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first) -> Data? {
        guard let item else { return nil }
        if let data = item.coverImageData, let thumbnail = make(data: data) { return thumbnail }
        if let path = item.coverLocalImagePath {
            var urls = [URL(fileURLWithPath: path)]
            if let range = path.range(of: "imagenes/collector/"),
               let support = applicationSupportURL {
                urls.append(support.appendingPathComponent(String(path[range.lowerBound...])))
            }
            for url in urls {
                if let data = try? Data(contentsOf: url, options: .mappedIfSafe), let thumbnail = make(data: data) { return thumbnail }
            }
        }
        return item.coverImageName.flatMap { UIImage(named: $0)?.jpegData(compressionQuality: 0.8) }.flatMap { make(data: $0) }
    }

    static func make(data: Data) -> Data? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: 160
              ] as CFDictionary) else { return nil }
        return UIImage(cgImage: image).jpegData(compressionQuality: 0.75)
    }
}
