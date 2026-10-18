import Foundation

@MainActor
final class HomeDiscoveryController: ObservableObject {
    @Published private(set) var suggestion: HomeDiscoverySuggestion?
    @Published private(set) var canShowAnother = false
    private var suggestions: [HomeDiscoverySuggestion] = []
    private let defaults: UserDefaults
    private static let lastSuggestionKey = "homeDiscovery.lastSuggestionID"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func refresh(categories: [CollectionCategory], chooseAnother: Bool = false) {
        let previousID = suggestion?.id
            ?? defaults.string(forKey: Self.lastSuggestionKey).flatMap(UUID.init(uuidString:))
        suggestions = HomeDiscoverySelection.suggestions(in: categories).shuffled()
        canShowAnother = suggestions.count > 1

        if !chooseAnother, let currentID = suggestion?.id,
           let current = suggestions.first(where: { $0.id == currentID }) {
            select(current)
        } else {
            select(suggestions.first(where: { $0.id != previousID }) ?? suggestions.first)
        }
    }

    func showAnother() {
        guard suggestions.count > 1, let current = suggestion,
              let index = suggestions.firstIndex(where: { $0.id == current.id }) else { return }
        select(suggestions[(index + 1) % suggestions.count])
    }

    private func select(_ suggestion: HomeDiscoverySuggestion?) {
        self.suggestion = suggestion
        if let suggestion {
            defaults.set(suggestion.id.uuidString, forKey: Self.lastSuggestionKey)
        }
    }
}
