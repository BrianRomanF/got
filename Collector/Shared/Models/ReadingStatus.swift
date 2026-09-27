import SwiftUI

enum ReadingStatus: String, CaseIterable, Hashable, Identifiable, Codable {
    case unread
    case reading
    case read

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .unread:
            L10n.ReadingStatus.unread
        case .reading:
            L10n.ReadingStatus.reading
        case .read:
            L10n.ReadingStatus.read
        }
    }

    var shortTitle: String {
        switch self {
        case .unread:
            L10n.ReadingStatus.unreadShort
        case .reading:
            L10n.ReadingStatus.readingShort
        case .read:
            L10n.ReadingStatus.readShort
        }
    }

    var symbolName: String {
        switch self {
        case .unread:
            "book.closed.fill"
        case .reading:
            "bookmark.fill"
        case .read:
            "checkmark.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .unread:
            ComicTheme.yellow
        case .reading:
            ComicTheme.blue
        case .read:
            ComicTheme.green
        }
    }
}
