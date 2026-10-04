import Foundation

enum GlobalSearchResultKind: Hashable {
    case category
    case shelf
    case piece

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
