import Foundation

enum DiscogsAPIError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case requestFailed

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return L10n.Discogs.missingAPIKey
        case .invalidURL:
            return L10n.Discogs.invalidURL
        case .requestFailed:
            return L10n.Discogs.requestFailed
        }
    }
}

final class DiscogsAPIClient {
    static let shared = DiscogsAPIClient()

    private let searchURL = URL(string: "https://api.discogs.com/database/search")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchReleases(query: String, format: DiscogsMediaFormat) async throws -> [DiscogsSearchResult] {
        guard var components = URLComponents(url: searchURL, resolvingAgainstBaseURL: false) else {
            throw DiscogsAPIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "release"),
            URLQueryItem(name: "format", value: format.rawValue),
            URLQueryItem(name: "per_page", value: "20"),
            URLQueryItem(name: "key", value: try credentials().key),
            URLQueryItem(name: "secret", value: try credentials().secret)
        ]

        guard let url = components.url else {
            throw DiscogsAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("GotItCollector/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw DiscogsAPIError.requestFailed
        }

        let decoded = try JSONDecoder().decode(DiscogsSearchResponse.self, from: data)

        return decoded.results.compactMap { result in
            guard let title = result.title, !title.isEmpty else { return nil }
            let titleParts = title.components(separatedBy: " - ")

            return DiscogsSearchResult(
                id: result.id,
                title: titleParts.last ?? title,
                artist: titleParts.count > 1 ? titleParts.dropLast().joined(separator: " - ") : nil,
                year: result.year,
                label: result.label?.first,
                format: format,
                coverURL: result.coverURL
            )
        }
    }

    private func credentials() throws -> (key: String, secret: String) {
        let savedConsumerKey = AppSettings.discogsConsumerKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let savedConsumerSecret = AppSettings.discogsConsumerSecret.trimmingCharacters(in: .whitespacesAndNewlines)
        let bundledConsumerKey = DiscogsAPIKey.consumerKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let bundledConsumerSecret = DiscogsAPIKey.consumerSecret.trimmingCharacters(in: .whitespacesAndNewlines)
        let consumerKey = savedConsumerKey.isEmpty ? bundledConsumerKey : savedConsumerKey
        let consumerSecret = savedConsumerSecret.isEmpty ? bundledConsumerSecret : savedConsumerSecret

        guard
            !consumerKey.isEmpty,
            !consumerSecret.isEmpty,
            consumerKey != "PASTE_YOUR_DISCOGS_CONSUMER_KEY_HERE",
            consumerSecret != "PASTE_YOUR_DISCOGS_CONSUMER_SECRET_HERE"
        else {
            throw DiscogsAPIError.missingAPIKey
        }

        return (consumerKey, consumerSecret)
    }
}

private struct DiscogsSearchResponse: Decodable {
    let results: [DiscogsReleaseDTO]
}

private struct DiscogsReleaseDTO: Decodable {
    let id: Int
    let title: String?
    let year: String?
    let label: [String]?
    let coverImage: String?
    let thumb: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case year
        case label
        case coverImage = "cover_image"
        case thumb
    }

    var coverURL: URL? {
        let value = coverImage ?? thumb
        return value.flatMap(URL.init(string:))
    }
}
