import Foundation

@MainActor
final class DiscogsSearchController: ObservableObject {
    @Published var query = ""
    @Published var selectedFormat: DiscogsMediaFormat = .vinyl
    @Published private(set) var results: [DiscogsSearchResult] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false

    private let client: DiscogsAPIClient

    init(client: DiscogsAPIClient = .shared) {
        self.client = client
    }

    func search() {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                results = try await client.searchReleases(query: trimmedQuery, format: selectedFormat)
            } catch {
                results = []
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }
}
