import Foundation

@MainActor
final class ComicVineSearchController: ObservableObject {
    @Published var query = ""
    @Published private(set) var results: [ComicVineIssueSearchResult] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false

    private let client: ComicVineAPIClient

    init(client: ComicVineAPIClient = .shared) {
        self.client = client
    }

    func search() {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                results = try await client.searchIssues(query: trimmedQuery)
            } catch {
                results = []
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }
}
