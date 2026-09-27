import Foundation

@MainActor
final class BookSearchController: ObservableObject {
    @Published var query = ""
    @Published private(set) var results: [BookSearchResult] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false

    private let client: BookSearchAPIClient

    init(client: BookSearchAPIClient = .shared) {
        self.client = client
    }

    func search() {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                results = try await client.searchBooks(query: trimmedQuery)
            } catch {
                results = []
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }
}
