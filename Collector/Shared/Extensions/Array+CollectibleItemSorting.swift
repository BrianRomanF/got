import Foundation

extension Array where Element == CollectibleItem {
    func sorted(using option: ItemSortOption) -> [CollectibleItem] {
        switch option {
        case .newest:
            return sorted { $0.createdAt > $1.createdAt }
        case .title:
            return sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .ownedFirst:
            return sorted {
                if $0.ownershipStatus != $1.ownershipStatus {
                    return $0.ownershipStatus == .owned
                }
                return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
        case .missingFirst:
            return sorted {
                if $0.ownershipStatus != $1.ownershipStatus {
                    return $0.ownershipStatus == .missing
                }
                return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
        case .rating:
            return sorted {
                let leftRating = $0.bookRating ?? 0
                let rightRating = $1.bookRating ?? 0
                if leftRating != rightRating {
                    return leftRating > rightRating
                }
                return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
        }
    }
}
