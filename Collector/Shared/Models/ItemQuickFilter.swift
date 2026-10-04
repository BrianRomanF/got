import Foundation

enum ItemQuickFilter: String, CaseIterable, Identifiable, Hashable {
    case all
    case notes
    case noCover
    case physical
    case digital

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .all:
            return L10n.Filters.all
        case .notes:
            return L10n.Filters.withNotes
        case .noCover:
            return L10n.Filters.noCover
        case .physical:
            return L10n.BookDetails.physical
        case .digital:
            return L10n.BookDetails.digital
        }
    }

    func includes(_ item: CollectibleItem) -> Bool {
        switch self {
        case .all:
            return true
        case .notes:
            return !item.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .noCover:
            return item.coverImageData == nil
                && item.coverLocalImagePath == nil
                && item.coverRemoteURL == nil
        case .physical:
            return item.bookFormat == .physical
        case .digital:
            return item.bookFormat == .digital
        }
    }
}
