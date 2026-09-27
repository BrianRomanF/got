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
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchBooks(query: String) async throws -> [BookSearchResult] {
        if let googleResults = try? await searchGoogleBooks(query: query), !googleResults.isEmpty {
            return googleResults
        }

        return try await searchOpenLibrary(query: query)
    }

    private func searchGoogleBooks(query: String) async throws -> [BookSearchResult] {
        let key = apiKey()
        guard !key.isEmpty else { return [] }
        guard var components = URLComponents(url: googleBooksURL, resolvingAgainstBaseURL: false) else {
            throw BookSearchAPIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "maxResults", value: "20"),
            URLQueryItem(name: "printType", value: "books"),
            URLQueryItem(name: "key", value: key)
        ]

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

        let (data, response) = try await session.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw BookSearchAPIError.requestFailed
        }

        return try JSONDecoder().decode(Response.self, from: data)
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
