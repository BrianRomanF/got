import Foundation

enum CustomCategoryContentMode: String, CaseIterable, Identifiable, Codable, Hashable {
    case shelvesAndPieces
    case shelvesOnly
    case piecesOnly

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .shelvesAndPieces:
            return L10n.CustomMode.shelvesAndPieces
        case .shelvesOnly:
            return L10n.CustomMode.shelvesOnly
        case .piecesOnly:
            return L10n.CustomMode.piecesOnly
        }
    }

    var description: String {
        switch self {
        case .shelvesAndPieces:
            return L10n.CustomMode.shelvesAndPiecesHint
        case .shelvesOnly:
            return L10n.CustomMode.shelvesOnlyHint
        case .piecesOnly:
            return L10n.CustomMode.piecesOnlyHint
        }
    }
}
