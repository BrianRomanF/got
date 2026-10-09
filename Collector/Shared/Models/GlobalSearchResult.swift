import Foundation

enum GlobalSearchResultKind: String, CaseIterable, Identifiable, Hashable {
    case category
    case shelf
    case piece

    var id: String { rawValue }

    var title: String {
        switch self {
        case .category:
            L10n.GlobalSearch.filterCategories
        case .shelf:
            L10n.GlobalSearch.filterShelves
        case .piece:
            L10n.GlobalSearch.filterPieces
        }
    }

    var symbolName: String {
        switch self {
        case .category:
            "square.grid.2x2.fill"
        case .shelf:
            "folder.fill"
        case .piece:
            "shippingbox.fill"
        }
    }
}

struct GlobalSearchResult: Identifiable, Hashable {
    let id: String
    let kind: GlobalSearchResultKind
    let title: String
    let subtitle: String
    let route: CollectorRoute
}
