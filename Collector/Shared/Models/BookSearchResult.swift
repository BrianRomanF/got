import Foundation

enum BookSearchProvider: String, Hashable {
    case googleBooks = "Google Books"
    case openLibrary = "Open Library"
}

struct BookSearchResult: Identifiable, Hashable {
    let id: String
    let provider: BookSearchProvider
    let title: String
    let authors: [String]
    let publishedYear: String?
    let publisher: String?
    let description: String?
    let coverURL: URL?

    var displaySubtitle: String {
        var parts: [String] = []

        if !authors.isEmpty {
            parts.append(authors.joined(separator: ", "))
        }

        if let publishedYear, !publishedYear.isEmpty {
            parts.append(publishedYear)
        }

        return parts.joined(separator: " - ")
    }
}
