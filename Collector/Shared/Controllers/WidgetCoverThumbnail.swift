import Foundation
import ImageIO
import UIKit

enum WidgetCoverThumbnail {
    static func make(from item: CollectibleItem?) -> Data? {
        guard let item else { return nil }
        let localData = item.coverLocalImagePath.flatMap { try? Data(contentsOf: URL(fileURLWithPath: $0), options: .mappedIfSafe) }
        let namedData = item.coverImageName.flatMap { UIImage(named: $0)?.jpegData(compressionQuality: 0.8) }
        guard let data = item.coverImageData ?? localData ?? namedData,
              let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: 160
              ] as CFDictionary) else { return nil }
        return UIImage(cgImage: image).jpegData(compressionQuality: 0.75)
    }
}
