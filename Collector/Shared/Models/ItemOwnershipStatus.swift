import SwiftUI

enum ItemOwnershipStatus: String, CaseIterable, Hashable, Identifiable, Codable {
    case owned
    case missing

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .owned:
            L10n.Ownership.owned
        case .missing:
            L10n.Ownership.missing
        }
    }

    var shortTitle: String {
        switch self {
        case .owned:
            L10n.Ownership.ownedShort
        case .missing:
            L10n.Ownership.missingShort
        }
    }

    var symbolName: String {
        switch self {
        case .owned:
            "checkmark.seal.fill"
        case .missing:
            "exclamationmark.triangle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .owned:
            ComicTheme.green
        case .missing:
            ComicTheme.red
        }
    }
}
