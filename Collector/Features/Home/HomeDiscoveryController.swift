import Foundation

@MainActor
final class HomeDiscoveryController: ObservableObject {
    @Published private(set) var suggestion: HomeDiscoverySuggestion?
    @Published private(set) var canShowAnother = false
    private var suggestions: [HomeDiscoverySuggestion] = []
    private var dayKey: String?

    func refresh(categories: [CollectionCategory], date: Date = .now, calendar: Calendar = .current) {
        let key = HomeDiscoverySelection.dayKey(for: date, calendar: calendar)
        let previousID = dayKey == key ? suggestion?.id : nil
        suggestions = HomeDiscoverySelection.suggestions(in: categories, date: date, calendar: calendar)
        suggestion = suggestions.first { $0.id == previousID } ?? suggestions.first
        canShowAnother = suggestions.count > 1
        dayKey = key
    }

    func showAnother() {
        guard suggestions.count > 1, let current = suggestion,
              let index = suggestions.firstIndex(where: { $0.id == current.id }) else { return }
        suggestion = suggestions[(index + 1) % suggestions.count]
    }
}
