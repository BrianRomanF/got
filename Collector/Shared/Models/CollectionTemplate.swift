import Foundation

enum CollectionTemplate: String, CaseIterable, Hashable, Identifiable, Codable {
    case comics
    case books
    case vinyl
    case games
    case tradingCards
    case collectibles
    case custom

    var id: String {
        rawValue
    }

    var supportsReadingStatus: Bool {
        switch self {
        case .comics, .books:
            true
        case .vinyl, .games, .tradingCards, .collectibles, .custom:
            false
        }
    }

    var topLevelGroupTitle: String {
        switch self {
        case .comics:
            L10n.Detail.groups
        case .books:
            L10n.Template.bookShelves
        case .vinyl:
            L10n.Template.vinylArtists
        case .games:
            L10n.Template.gamePlatforms
        case .tradingCards:
            L10n.Template.cardSets
        case .collectibles, .custom:
            L10n.Detail.groups
        }
    }

    var addTopLevelGroupTitle: String {
        switch self {
        case .comics:
            L10n.Detail.addGroup
        case .books:
            L10n.Template.addBookShelf
        case .vinyl:
            L10n.Template.addVinylArtist
        case .games:
            L10n.Template.addGamePlatform
        case .tradingCards:
            L10n.Template.addCardSet
        case .collectibles, .custom:
            L10n.Detail.addGroup
        }
    }

    var topLevelGroupNamePlaceholder: String {
        switch self {
        case .comics:
            L10n.Detail.groupName
        case .books:
            L10n.Template.bookShelfName
        case .vinyl:
            L10n.Template.vinylArtistName
        case .games:
            L10n.Template.gamePlatformName
        case .tradingCards:
            L10n.Template.cardSetName
        case .collectibles, .custom:
            L10n.Detail.groupName
        }
    }

    var itemTitle: String {
        switch self {
        case .comics:
            L10n.Template.comicIssues
        case .books:
            L10n.Template.books
        case .vinyl:
            L10n.Template.vinylAlbums
        case .games:
            L10n.Template.games
        case .tradingCards:
            L10n.Template.cards
        case .collectibles, .custom:
            L10n.Detail.items
        }
    }

    var shouldShowTopLevelItemsWhenEmpty: Bool {
        switch self {
        case .custom:
            true
        case .comics, .books, .vinyl, .games, .tradingCards, .collectibles:
            false
        }
    }

    var creationTitle: String {
        switch self {
        case .comics:
            return L10n.Template.comicsCategory
        case .books:
            return L10n.Template.booksCategory
        case .vinyl:
            return L10n.Template.vinylCategory
        case .games:
            return L10n.Template.gamesCategory
        case .tradingCards:
            return L10n.Template.cardsCategory
        case .collectibles:
            return L10n.Template.collectiblesCategory
        case .custom:
            return L10n.Template.customCategory
        }
    }

    var creationSubtitle: String {
        switch self {
        case .comics:
            return L10n.Template.comicsCategoryHint
        case .books:
            return L10n.Template.booksCategoryHint
        case .vinyl:
            return L10n.Template.vinylCategoryHint
        case .games:
            return L10n.Template.gamesCategoryHint
        case .tradingCards:
            return L10n.Template.cardsCategoryHint
        case .collectibles:
            return L10n.Template.collectiblesCategoryHint
        case .custom:
            return L10n.Template.customCategoryHint
        }
    }

    var defaultSymbolName: String {
        switch self {
        case .comics:
            return "book.closed.fill"
        case .books:
            return "books.vertical.fill"
        case .vinyl:
            return "record.circle.fill"
        case .games:
            return "gamecontroller.fill"
        case .tradingCards:
            return "rectangle.stack.fill"
        case .collectibles:
            return "star.square.fill"
        case .custom:
            return "square.grid.2x2.fill"
        }
    }
}
