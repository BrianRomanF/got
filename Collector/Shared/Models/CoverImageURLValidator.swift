import Foundation

enum CoverImageURLValidator {
    static func directImageURL(from value: String) -> URL? {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            let url = URL(string: trimmedValue),
            let scheme = url.scheme?.lowercased(),
            scheme == "https" || scheme == "http",
            url.host != nil
        else {
            return nil
        }

        let imageExtensions = ["jpg", "jpeg", "png", "webp", "gif"]
        guard imageExtensions.contains(url.pathExtension.lowercased()) else {
            return nil
        }

        return url
    }
}
