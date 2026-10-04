import Foundation

enum ItemDisplayMode: String, CaseIterable, Identifiable, Hashable {
    case grid
    case gallery

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .grid:
            return L10n.DisplayMode.grid
        case .gallery:
            return L10n.DisplayMode.gallery
        }
    }

    var systemName: String {
        switch self {
        case .grid:
            return "square.grid.2x2.fill"
        case .gallery:
            return "rectangle.stack.fill"
        }
    }
}
