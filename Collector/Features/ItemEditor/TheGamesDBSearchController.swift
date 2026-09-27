import Foundation

@MainActor
final class TheGamesDBSearchController: ObservableObject {
    @Published var query = ""
    @Published private(set) var results: [TheGamesDBGameSearchResult] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false

    private let client: TheGamesDBAPIClient

    init(client: TheGamesDBAPIClient = .shared) {
        self.client = client
    }

    func search() {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                results = try await client.searchGames(query: trimmedQuery)
            } catch {
                results = []
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }
}
