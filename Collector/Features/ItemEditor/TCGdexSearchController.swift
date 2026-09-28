import Foundation

@MainActor
final class TCGdexSearchController: ObservableObject {
    @Published var query = ""
    @Published private(set) var results: [TCGdexCardSearchResult] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false

    private let client: TCGdexAPIClient

    init(client: TCGdexAPIClient = .shared) {
        self.client = client
    }

    func search() {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                results = try await client.searchCards(query: trimmedQuery)
            } catch {
                results = []
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }
}
