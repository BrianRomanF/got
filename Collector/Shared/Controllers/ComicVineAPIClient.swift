import Foundation

enum ComicVineAPIError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case requestFailed
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return L10n.ComicVine.missingAPIKey
        case .invalidURL:
            return L10n.ComicVine.invalidURL
        case .requestFailed:
            return L10n.ComicVine.requestFailed
        case .apiError(let message):
            return message
        }
    }
}

final class ComicVineAPIClient {
    static let shared = ComicVineAPIClient()

    private let searchURL = URL(string: "https://comicvine.gamespot.com/api/search/")!
    private let issuesURL = URL(string: "https://comicvine.gamespot.com/api/issues/")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchIssues(query: String) async throws -> [ComicVineIssueSearchResult] {
        guard var components = URLComponents(url: searchURL, resolvingAgainstBaseURL: false) else {
            throw ComicVineAPIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "api_key", value: try apiKey()),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "resources", value: "issue"),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "field_list", value: "id,name,issue_number,image,cover_date,store_date,volume,site_detail_url")
        ]

        let apiResponse = try await decodedResponse(ComicVineIssueSearchResponse.self, components: components)
        guard apiResponse.statusCode == 1 else {
            throw ComicVineAPIError.apiError(apiResponse.error)
        }

        return apiResponse.results.map(\.searchResult)
    }

    func searchVolumes(query: String) async throws -> [ComicVineVolumeSearchResult] {
        guard var components = URLComponents(url: searchURL, resolvingAgainstBaseURL: false) else {
            throw ComicVineAPIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "api_key", value: try apiKey()),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "resources", value: "volume"),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "field_list", value: "id,name,start_year,publisher,count_of_issues,image,site_detail_url")
        ]

        let apiResponse = try await decodedResponse(ComicVineVolumeSearchResponse.self, components: components)
        guard apiResponse.statusCode == 1 else {
            throw ComicVineAPIError.apiError(apiResponse.error)
        }

        return apiResponse.results.map(\.searchResult)
    }

    func issues(in volume: ComicVineVolumeSearchResult) async throws -> [ComicVineIssueSearchResult] {
        let pageSize = 100
        var offset = 0
        var allIssues: [ComicVineIssueSearchResult] = []

        while true {
            let page = try await issuePage(volumeID: volume.id, limit: pageSize, offset: offset)
            allIssues.append(contentsOf: page.results.map(\.searchResult))

            offset += page.numberOfPageResults

            if page.numberOfPageResults == 0 || offset >= page.numberOfTotalResults {
                break
            }
        }

        return allIssues.sorted { lhs, rhs in
            lhs.issueNumber.localizedStandardCompare(rhs.issueNumber) == .orderedAscending
        }
    }

    private func issuePage(volumeID: Int, limit: Int, offset: Int) async throws -> ComicVineIssuesResponse {
        guard var components = URLComponents(url: issuesURL, resolvingAgainstBaseURL: false) else {
            throw ComicVineAPIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "api_key", value: try apiKey()),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "filter", value: "volume:\(volumeID)"),
            URLQueryItem(name: "sort", value: "issue_number:asc"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "field_list", value: "id,name,issue_number,image,cover_date,store_date,volume,site_detail_url")
        ]

        let apiResponse = try await decodedResponse(ComicVineIssuesResponse.self, components: components)
        guard apiResponse.statusCode == 1 else {
            throw ComicVineAPIError.apiError(apiResponse.error)
        }

        return apiResponse
    }

    private func apiKey() throws -> String {
        let savedAPIKey = AppSettings.comicVineAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let bundledAPIKey = ComicVineAPIKey.value.trimmingCharacters(in: .whitespacesAndNewlines)
        let apiKey = savedAPIKey.isEmpty ? bundledAPIKey : savedAPIKey

        guard !apiKey.isEmpty, apiKey != "PASTE_YOUR_COMIC_VINE_API_KEY_HERE" else {
            throw ComicVineAPIError.missingAPIKey
        }

        return apiKey
    }

    private func decodedResponse<Response: Decodable>(_ type: Response.Type, components: URLComponents) async throws -> Response {
        guard let url = components.url else {
            throw ComicVineAPIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw ComicVineAPIError.requestFailed
        }

        return try JSONDecoder().decode(Response.self, from: data)
    }
}

private struct ComicVineIssueSearchResponse: Decodable {
    let statusCode: Int
    let error: String
    let results: [ComicVineIssueDTO]

    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case error
        case results
    }
}

private struct ComicVineIssuesResponse: Decodable {
    let statusCode: Int
    let error: String
    let numberOfPageResults: Int
    let numberOfTotalResults: Int
    let results: [ComicVineIssueDTO]

    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case error
        case numberOfPageResults = "number_of_page_results"
        case numberOfTotalResults = "number_of_total_results"
        case results
    }
}

private struct ComicVineVolumeSearchResponse: Decodable {
    let statusCode: Int
    let error: String
    let results: [ComicVineVolumeSearchDTO]

    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case error
        case results
    }
}

private struct ComicVineVolumeSearchDTO: Decodable {
    let id: Int
    let name: String?
    let startYear: String?
    let publisher: ComicVinePublisherDTO?
    let issueCount: Int?
    let image: ComicVineImageDTO?
    let siteDetailURL: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case startYear = "start_year"
        case publisher
        case issueCount = "count_of_issues"
        case image
        case siteDetailURL = "site_detail_url"
    }

    var searchResult: ComicVineVolumeSearchResult {
        ComicVineVolumeSearchResult(
            id: id,
            name: name ?? "",
            startYear: startYear,
            publisherName: publisher?.name,
            issueCount: issueCount,
            imageURL: image?.bestURL,
            siteURL: siteDetailURL.flatMap(URL.init(string:))
        )
    }
}

private struct ComicVineIssueDTO: Decodable {
    let id: Int
    let name: String?
    let issueNumber: String?
    let image: ComicVineImageDTO?
    let coverDate: String?
    let storeDate: String?
    let volume: ComicVineVolumeDTO?
    let siteDetailURL: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case issueNumber = "issue_number"
        case image
        case coverDate = "cover_date"
        case storeDate = "store_date"
        case volume
        case siteDetailURL = "site_detail_url"
    }

    var searchResult: ComicVineIssueSearchResult {
        ComicVineIssueSearchResult(
            id: id,
            name: name ?? "",
            issueNumber: issueNumber ?? "",
            volumeName: volume?.name ?? "",
            coverDate: coverDate,
            storeDate: storeDate,
            imageURL: image?.bestURL,
            siteURL: siteDetailURL.flatMap(URL.init(string:))
        )
    }
}

private struct ComicVineImageDTO: Decodable {
    let originalURL: String?
    let superURL: String?
    let mediumURL: String?
    let smallURL: String?

    enum CodingKeys: String, CodingKey {
        case originalURL = "original_url"
        case superURL = "super_url"
        case mediumURL = "medium_url"
        case smallURL = "small_url"
    }

    var bestURL: URL? {
        [originalURL, superURL, mediumURL, smallURL]
            .compactMap { $0 }
            .compactMap(URL.init(string:))
            .first
    }
}

private struct ComicVineVolumeDTO: Decodable {
    let name: String?
}

private struct ComicVinePublisherDTO: Decodable {
    let name: String?
}
