import Foundation

enum DiscogsMediaFormat: String, CaseIterable, Identifiable {
    case vinyl = "Vinyl"
    case cassette = "Cassette"

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .vinyl:
            return L10n.Discogs.vinyl
        case .cassette:
            return L10n.Discogs.cassette
        }
    }
}

struct DiscogsSearchResult: Identifiable, Hashable {
    let id: Int
    let title: String
    let artist: String?
    let year: String?
    let label: String?
    let format: DiscogsMediaFormat
    let coverURL: URL?

    var displaySubtitle: String {
        var parts: [String] = []

        if let artist, !artist.isEmpty {
            parts.append(artist)
        }

        if let year, !year.isEmpty {
            parts.append(year)
        }

        if let label, !label.isEmpty {
            parts.append(label)
        }

        return parts.joined(separator: " - ")
    }
}
