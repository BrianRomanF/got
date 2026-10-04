import Foundation

enum ItemSortOption: String, CaseIterable, Identifiable, Hashable {
    case newest
    case number
    case title
    case ownedFirst
    case missingFirst
    case rating

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .newest:
            return L10n.Sort.newest
        case .number:
            return L10n.Sort.number
        case .title:
            return L10n.Sort.title
        case .ownedFirst:
            return L10n.Sort.ownedFirst
        case .missingFirst:
            return L10n.Sort.missingFirst
        case .rating:
            return L10n.Sort.rating
        }
    }
}
