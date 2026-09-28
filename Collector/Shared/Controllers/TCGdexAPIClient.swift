import Foundation

enum TCGdexAPIError: LocalizedError {
    case invalidURL
    case requestFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return L10n.TCGdex.invalidURL
        case .requestFailed:
            return L10n.TCGdex.requestFailed
        }
    }
}

final class TCGdexAPIClient {
    static let shared = TCGdexAPIClient()

    private let cardsURL = URL(string: "https://api.tcgdex.net/v2/en/cards")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchCards(query: String) async throws -> [TCGdexCardSearchResult] {
        guard var components = URLComponents(url: cardsURL, resolvingAgainstBaseURL: false) else {
            throw TCGdexAPIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "name", value: query),
            URLQueryItem(name: "pagination:page", value: "1"),
            URLQueryItem(name: "pagination:itemsPerPage", value: "30")
        ]

        guard let url = components.url else {
            throw TCGdexAPIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw TCGdexAPIError.requestFailed
        }

        let decoded = try JSONDecoder().decode([TCGdexCardDTO].self, from: data)
        return decoded.map { card in
            TCGdexCardSearchResult(
                id: card.id,
                name: card.name,
                localID: card.localID,
                imageURL: card.image.flatMap { URL(string: "\($0).png") }
            )
        }
    }
}

private struct TCGdexCardDTO: Decodable {
    let id: String
    let localID: String?
    let name: String
    let image: String?

    enum CodingKeys: String, CodingKey {
        case id
        case localID = "localId"
        case name
        case image
    }
}
