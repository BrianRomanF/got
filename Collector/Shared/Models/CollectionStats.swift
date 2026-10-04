import Foundation

struct CollectionStats: Hashable {
    let totalItems: Int
    let ownedItems: Int
    let missingItems: Int
    let groups: Int

    var completionRatio: Double {
        guard totalItems > 0 else { return 0 }
        return Double(ownedItems) / Double(totalItems)
    }
}
