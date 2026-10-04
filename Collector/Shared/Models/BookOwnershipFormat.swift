import Foundation

enum BookOwnershipFormat: String, CaseIterable, Identifiable, Codable, Hashable {
    case physical
    case digital

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .physical:
            return L10n.BookDetails.physical
        case .digital:
            return L10n.BookDetails.digital
        }
    }
}
