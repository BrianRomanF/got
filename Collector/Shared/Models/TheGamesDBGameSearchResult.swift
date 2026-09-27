import Foundation

struct TheGamesDBGameSearchResult: Identifiable, Hashable {
    let id: Int
    let title: String
    let releaseDate: String?
    let platformName: String?
    let overview: String?
    let boxartURL: URL?

    var displaySubtitle: String {
        var parts: [String] = []

        if let platformName, !platformName.isEmpty {
            parts.append(platformName)
        }

        if let releaseDate, !releaseDate.isEmpty {
            parts.append(releaseDate)
        }

        return parts.joined(separator: " - ")
    }
}
