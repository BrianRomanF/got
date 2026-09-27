import Foundation

enum ItemOwnershipFilter: String, CaseIterable, Hashable, Identifiable {
    case all
    case owned
    case missing

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .all:
            L10n.OwnershipFilter.all
        case .owned:
            L10n.OwnershipFilter.owned
        case .missing:
            L10n.OwnershipFilter.missing
        }
    }

    func includes(_ item: CollectibleItem) -> Bool {
        switch self {
        case .all:
            true
        case .owned:
            item.ownershipStatus == .owned
        case .missing:
            item.ownershipStatus == .missing
        }
    }
}
