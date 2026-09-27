import Foundation

enum TheGamesDBAPIError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case requestFailed
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return L10n.TheGamesDB.missingAPIKey
        case .invalidURL:
            return L10n.TheGamesDB.invalidURL
        case .requestFailed:
            return L10n.TheGamesDB.requestFailed
        case .apiError(let message):
            return message
        }
    }
}

final class TheGamesDBAPIClient {
    static let shared = TheGamesDBAPIClient()

    private let gameNameURL = URL(string: "https://api.thegamesdb.net/v1.1/Games/ByGameName")!
    private let gameImagesURL = URL(string: "https://api.thegamesdb.net/v1/Games/Images")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchGames(query: String) async throws -> [TheGamesDBGameSearchResult] {
        let games = try await gamesByName(query: query)
        let ids = games.map(\.id)
        let imageLookup = try await imagesByGameID(ids: ids)

        return games.map { game in
            TheGamesDBGameSearchResult(
                id: game.id,
                title: game.title,
                releaseDate: game.releaseDate,
                platformName: game.platformName,
                overview: game.overview,
                boxartURL: imageLookup[game.id]
            )
        }
    }

    private func gamesByName(query: String) async throws -> [TheGamesDBGameDTO] {
        guard var components = URLComponents(url: gameNameURL, resolvingAgainstBaseURL: false) else {
            throw TheGamesDBAPIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "apikey", value: try apiKey()),
            URLQueryItem(name: "name", value: query),
            URLQueryItem(name: "fields", value: "overview,platform,players,publishers,genres"),
            URLQueryItem(name: "include", value: "platform")
        ]

        let response = try await decodedResponse(TheGamesDBGamesResponse.self, components: components)
        guard response.code == 200 else {
            throw TheGamesDBAPIError.apiError(response.status ?? L10n.TheGamesDB.requestFailed)
        }

        return response.data?.games ?? []
    }

    private func imagesByGameID(ids: [Int]) async throws -> [Int: URL] {
        guard !ids.isEmpty else { return [:] }
        guard var components = URLComponents(url: gameImagesURL, resolvingAgainstBaseURL: false) else {
            throw TheGamesDBAPIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "apikey", value: try apiKey()),
            URLQueryItem(name: "games_id", value: ids.map(String.init).joined(separator: ","))
        ]

        let response = try await decodedResponse(TheGamesDBImagesResponse.self, components: components)
        guard response.code == 200 else {
            throw TheGamesDBAPIError.apiError(response.status ?? L10n.TheGamesDB.requestFailed)
        }

        guard let baseURLString = response.data?.baseURL?.bestURLString else { return [:] }

        var lookup: [Int: URL] = [:]

        response.data?.images?.forEach { key, images in
            guard let gameID = Int(key) else { return }
            let preferredImage = images.first { $0.type == "boxart" && $0.side == "front" }
                ?? images.first { $0.type == "boxart" }
                ?? images.first

            guard let filename = preferredImage?.filename else { return }
            lookup[gameID] = URL(string: baseURLString + filename)
        }

        return lookup
    }

    private func apiKey() throws -> String {
        let savedAPIKey = AppSettings.theGamesDBAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let bundledAPIKey = TheGamesDBAPIKey.value.trimmingCharacters(in: .whitespacesAndNewlines)
        let apiKey = savedAPIKey.isEmpty ? bundledAPIKey : savedAPIKey

        guard !apiKey.isEmpty, apiKey != "PASTE_YOUR_THEGAMESDB_API_KEY_HERE" else {
            throw TheGamesDBAPIError.missingAPIKey
        }

        return apiKey
    }

    private func decodedResponse<Response: Decodable>(_ type: Response.Type, components: URLComponents) async throws -> Response {
        guard let url = components.url else {
            throw TheGamesDBAPIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw TheGamesDBAPIError.requestFailed
        }

        return try JSONDecoder().decode(Response.self, from: data)
    }
}

private struct TheGamesDBGamesResponse: Decodable {
    let code: Int
    let status: String?
    let data: TheGamesDBGamesDataDTO?
}

private struct TheGamesDBGamesDataDTO: Decodable {
    let games: [TheGamesDBGameDTO]?
}

private struct TheGamesDBGameDTO: Decodable {
    let id: Int
    let title: String
    let releaseDate: String?
    let platformName: String?
    let overview: String?

    enum CodingKeys: String, CodingKey {
        case id
        case gameTitle = "game_title"
        case releaseDate = "release_date"
        case platform
        case platformName = "platform_name"
        case overview
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = (try? container.decode(String.self, forKey: .gameTitle)) ?? ""
        releaseDate = try? container.decode(String.self, forKey: .releaseDate)
        overview = try? container.decode(String.self, forKey: .overview)
        platformName = (try? container.decode(String.self, forKey: .platformName))
            ?? (try? container.decode(TheGamesDBPlatformDTO.self, forKey: .platform).name)
    }
}

private struct TheGamesDBPlatformDTO: Decodable {
    let name: String?
}

private struct TheGamesDBImagesResponse: Decodable {
    let code: Int
    let status: String?
    let data: TheGamesDBImagesDataDTO?
}

private struct TheGamesDBImagesDataDTO: Decodable {
    let baseURL: TheGamesDBImageBaseURLDTO?
    let images: [String: [TheGamesDBImageDTO]]?

    enum CodingKeys: String, CodingKey {
        case baseURL = "base_url"
        case images
    }
}

private struct TheGamesDBImageBaseURLDTO: Decodable {
    let original: String?
    let small: String?
    let thumb: String?

    var bestURLString: String? {
        original ?? small ?? thumb
    }
}

private struct TheGamesDBImageDTO: Decodable {
    let type: String?
    let side: String?
    let filename: String?
}
