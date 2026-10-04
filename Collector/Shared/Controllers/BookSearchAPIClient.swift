import Foundation

enum BookSearchAPIError: LocalizedError {
    case invalidURL
    case requestFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return L10n.BookSearch.invalidURL
        case .requestFailed:
            return L10n.BookSearch.requestFailed
        }
    }
}

final class BookSearchAPIClient {
    static let shared = BookSearchAPIClient()

    private let googleBooksURL = URL(string: "https://www.googleapis.com/books/v1/volumes")!
    private let openLibraryURL = URL(string: "https://openlibrary.org/search.json")!
    private let openLibraryISBNBaseURL = URL(string: "https://openlibrary.org/isbn")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchBooks(query: String) async throws -> [BookSearchResult] {
        let normalizedQuery = normalizedBookQuery(from: query)

        if let googleResults = try? await searchGoogleBooks(query: normalizedQuery.googleQuery), !googleResults.isEmpty {
            return googleResults
        }

        if let isbn = normalizedQuery.isbn,
           let openLibraryISBNResult = try? await searchOpenLibraryISBN(isbn: isbn),
           !openLibraryISBNResult.isEmpty {
            return openLibraryISBNResult
        }

        return try await searchOpenLibrary(query: normalizedQuery.openLibraryQuery)
    }

    private func searchGoogleBooks(query: String) async throws -> [BookSearchResult] {
        let key = apiKey()
        guard var components = URLComponents(url: googleBooksURL, resolvingAgainstBaseURL: false) else {
            throw BookSearchAPIError.invalidURL
        }

        var queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "maxResults", value: "20"),
            URLQueryItem(name: "printType", value: "books")
        ]

        if !key.isEmpty {
            queryItems.append(URLQueryItem(name: "key", value: key))
        }

        components.queryItems = queryItems

        let response = try await decodedResponse(GoogleBooksResponse.self, components: components)

        return response.items?.compactMap { item in
            guard let title = item.volumeInfo.title, !title.isEmpty else { return nil }

            return BookSearchResult(
                id: "google-\(item.id)",
                provider: .googleBooks,
                title: title,
                authors: item.volumeInfo.authors ?? [],
                publishedYear: item.volumeInfo.publishedDate?.split(separator: "-").first.map(String.init),
                publisher: item.volumeInfo.publisher,
                description: item.volumeInfo.description,
                coverURL: item.volumeInfo.imageLinks?.bestURL
            )
        } ?? []
    }

    private func searchOpenLibraryISBN(isbn: String) async throws -> [BookSearchResult] {
        let url = openLibraryISBNBaseURL
            .appendingPathComponent(isbn)
            .appendingPathExtension("json")

        let book = try await decodedResponse(OpenLibraryISBNBookDTO.self, url: url)
        guard let title = book.title, !title.isEmpty else { return [] }

        return [
            BookSearchResult(
                id: "openlibrary-isbn-\(isbn)",
                provider: .openLibrary,
                title: title,
                authors: book.authorNames,
                publishedYear: book.publishedYear,
                publisher: book.publishers?.first,
                description: book.descriptionText,
                coverURL: book.coverURL(isbn: isbn)
            )
        ]
    }

    private func searchOpenLibrary(query: String) async throws -> [BookSearchResult] {
        guard var components = URLComponents(url: openLibraryURL, resolvingAgainstBaseURL: false) else {
            throw BookSearchAPIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "fields", value: "key,title,author_name,first_publish_year,publisher,cover_i")
        ]

        let response = try await decodedResponse(OpenLibraryResponse.self, components: components)

        return response.docs.compactMap { book in
            guard let title = book.title, !title.isEmpty else { return nil }

            return BookSearchResult(
                id: "openlibrary-\(book.key ?? title)",
                provider: .openLibrary,
                title: title,
                authors: book.authorNames ?? [],
                publishedYear: book.firstPublishYear.map(String.init),
                publisher: book.publishers?.first,
                description: nil,
                coverURL: book.coverURL
            )
        }
    }

    private func apiKey() -> String {
        let savedAPIKey = AppSettings.googleBooksAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let bundledAPIKey = GoogleBooksAPIKey.value.trimmingCharacters(in: .whitespacesAndNewlines)
        let apiKey = savedAPIKey.isEmpty ? bundledAPIKey : savedAPIKey

        return apiKey == "PASTE_YOUR_GOOGLE_BOOKS_API_KEY_HERE" ? "" : apiKey
    }

    private func decodedResponse<Response: Decodable>(_ type: Response.Type, components: URLComponents) async throws -> Response {
        guard let url = components.url else {
            throw BookSearchAPIError.invalidURL
        }

        return try await decodedResponse(type, url: url)
    }

    private func decodedResponse<Response: Decodable>(_ type: Response.Type, url: URL) async throws -> Response {
        let (data, response) = try await session.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw BookSearchAPIError.requestFailed
        }

        return try JSONDecoder().decode(Response.self, from: data)
    }

    private func normalizedBookQuery(from query: String) -> (googleQuery: String, openLibraryQuery: String, isbn: String?) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let isbn = trimmed
            .uppercased()
            .filter { $0.isNumber || $0 == "X" }

        if isbn.count == 10 || isbn.count == 13 {
            return ("isbn:\(isbn)", isbn, isbn)
        }

        return (trimmed, trimmed, nil)
    }
}

private struct GoogleBooksResponse: Decodable {
    let items: [GoogleBookItemDTO]?
}

private struct GoogleBookItemDTO: Decodable {
    let id: String
    let volumeInfo: GoogleBookVolumeInfoDTO
}

private struct GoogleBookVolumeInfoDTO: Decodable {
    let title: String?
    let authors: [String]?
    let publisher: String?
    let publishedDate: String?
    let description: String?
    let imageLinks: GoogleBookImageLinksDTO?
}

private struct GoogleBookImageLinksDTO: Decodable {
    let thumbnail: String?
    let smallThumbnail: String?

    var bestURL: URL? {
        let value = thumbnail ?? smallThumbnail
        return value.flatMap { URL(string: $0.replacingOccurrences(of: "http://", with: "https://")) }
    }
}

private struct OpenLibraryResponse: Decodable {
    let docs: [OpenLibraryBookDTO]
}

private struct OpenLibraryISBNBookDTO: Decodable {
    let title: String?
    let publishDate: String?
    let publishers: [String]?
    let covers: [Int]?
    let byStatement: String?
    let description: OpenLibraryDescriptionDTO?
    let notes: OpenLibraryDescriptionDTO?

    enum CodingKeys: String, CodingKey {
        case title
        case publishDate = "publish_date"
        case publishers
        case covers
        case byStatement = "by_statement"
        case description
        case notes
    }

    var authorNames: [String] {
        guard let byStatement, !byStatement.isEmpty else { return [] }
        return [byStatement]
    }

    var publishedYear: String? {
        publishDate?.split(whereSeparator: { !$0.isNumber }).first.map(String.init)
    }

    var descriptionText: String? {
        description?.text ?? notes?.text
    }

    func coverURL(isbn: String) -> URL? {
        if let coverID = covers?.first {
            return URL(string: "https://covers.openlibrary.org/b/id/\(coverID)-L.jpg")
        }

        return URL(string: "https://covers.openlibrary.org/b/isbn/\(isbn)-L.jpg")
    }
}

private struct OpenLibraryDescriptionDTO: Decodable {
    let text: String?

    init(from decoder: Decoder) throws {
        if let text = try? decoder.singleValueContainer().decode(String.self) {
            self.text = text
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decodeIfPresent(String.self, forKey: .value)
    }

    private enum CodingKeys: String, CodingKey {
        case value
    }
}

private struct OpenLibraryBookDTO: Decodable {
    let key: String?
    let title: String?
    let coverID: Int?
    let authorNames: [String]?
    let firstPublishYear: Int?
    let publishers: [String]?

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case coverID = "cover_i"
        case authorNames = "author_name"
        case firstPublishYear = "first_publish_year"
        case publishers = "publisher"
    }

    var coverURL: URL? {
        coverID.flatMap { URL(string: "https://covers.openlibrary.org/b/id/\($0)-L.jpg") }
    }
}
