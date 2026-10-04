import Foundation

enum L10n {
    enum Common {
        static var add: String { tr("common.add") }
        static var cancel: String { tr("common.cancel") }
        static var save: String { tr("common.save") }
        static var title: String { tr("common.title") }
        static var subtitle: String { tr("common.subtitle") }
        static var notes: String { tr("common.notes") }
    }

    enum Home {
        static var title: String { tr("home.title") }
        static var eyebrow: String { tr("home.eyebrow") }
        static var empty: String { tr("home.empty") }
        static var addCategory: String { tr("home.addCategory") }
        static var newCategoryHint: String { tr("home.newCategoryHint") }
        static var editCategory: String { tr("home.editCategory") }
        static var editCategoryHint: String { tr("home.editCategoryHint") }
        static var deleteCategory: String { tr("home.deleteCategory") }
        static var deleteCategoryTitle: String { tr("home.deleteCategoryTitle") }
        static var deleteCategoryMessage: String { tr("home.deleteCategoryMessage") }
        static var categoryType: String { tr("home.categoryType") }
        static var categoryTypeHint: String { tr("home.categoryTypeHint") }
        static var categoryName: String { tr("home.categoryName") }
        static var categorySubtitle: String { tr("home.categorySubtitle") }
        static var categorySVGIconTitle: String { tr("home.categorySVGIconTitle") }
        static var categorySVGIconURL: String { tr("home.categorySVGIconURL") }
        static var categorySVGIconSelectFile: String { tr("home.categorySVGIconSelectFile") }
        static var categorySVGIconHint: String { tr("home.categorySVGIconHint") }
    }

    enum Settings {
        static var title: String { tr("settings.title") }
        static var eyebrow: String { tr("settings.eyebrow") }
        static var languageTitle: String { tr("settings.languageTitle") }
        static var languageSystem: String { tr("settings.languageSystem") }
        static var languageEnglish: String { tr("settings.languageEnglish") }
        static var languageSpanish: String { tr("settings.languageSpanish") }
        static var onboardingTitle: String { tr("settings.onboardingTitle") }
        static var hideOnboarding: String { tr("settings.hideOnboarding") }
        static var hideOnboardingHint: String { tr("settings.hideOnboardingHint") }
        static var comicVineTitle: String { tr("settings.comicVineTitle") }
        static var comicVineAPIKeyPlaceholder: String { tr("settings.comicVineAPIKeyPlaceholder") }
        static var comicVineGuideTitle: String { tr("settings.comicVineGuideTitle") }
        static var comicVineGuideBody: String { tr("settings.comicVineGuideBody") }
        static var comicVineOpenAPIPage: String { tr("settings.comicVineOpenAPIPage") }
        static var theGamesDBTitle: String { tr("settings.theGamesDBTitle") }
        static var theGamesDBAPIKeyPlaceholder: String { tr("settings.theGamesDBAPIKeyPlaceholder") }
        static var theGamesDBGuideTitle: String { tr("settings.theGamesDBGuideTitle") }
        static var theGamesDBGuideBody: String { tr("settings.theGamesDBGuideBody") }
        static var theGamesDBOpenAPIPage: String { tr("settings.theGamesDBOpenAPIPage") }
        static var googleBooksTitle: String { tr("settings.googleBooksTitle") }
        static var googleBooksAPIKeyPlaceholder: String { tr("settings.googleBooksAPIKeyPlaceholder") }
        static var googleBooksGuideTitle: String { tr("settings.googleBooksGuideTitle") }
        static var googleBooksGuideBody: String { tr("settings.googleBooksGuideBody") }
        static var googleBooksOpenAPIPage: String { tr("settings.googleBooksOpenAPIPage") }
        static var discogsTitle: String { tr("settings.discogsTitle") }
        static var discogsConsumerKeyPlaceholder: String { tr("settings.discogsConsumerKeyPlaceholder") }
        static var discogsConsumerSecretPlaceholder: String { tr("settings.discogsConsumerSecretPlaceholder") }
        static var discogsGuideTitle: String { tr("settings.discogsGuideTitle") }
        static var discogsGuideBody: String { tr("settings.discogsGuideBody") }
        static var discogsOpenAPIPage: String { tr("settings.discogsOpenAPIPage") }
        static var usageGuideTitle: String { tr("settings.usageGuideTitle") }
        static var guideCollectionsTitle: String { tr("settings.guideCollectionsTitle") }
        static var guideCollectionsBody: String { tr("settings.guideCollectionsBody") }
        static var guideShelvesTitle: String { tr("settings.guideShelvesTitle") }
        static var guideShelvesBody: String { tr("settings.guideShelvesBody") }
        static var guideCoversTitle: String { tr("settings.guideCoversTitle") }
        static var guideCoversBody: String { tr("settings.guideCoversBody") }
        static var guideTrackingTitle: String { tr("settings.guideTrackingTitle") }
        static var guideTrackingBody: String { tr("settings.guideTrackingBody") }
        static var apiSectionTitle: String { tr("settings.apiSectionTitle") }
        static var apiPrivacyBody: String { tr("settings.apiPrivacyBody") }
        static var editAPIKeys: String { tr("settings.editAPIKeys") }
        static var hideAPIKeys: String { tr("settings.hideAPIKeys") }
        static var apiConfigured: String { tr("settings.apiConfigured") }
        static var apiNotConfigured: String { tr("settings.apiNotConfigured") }
        static var backupTitle: String { tr("settings.backupTitle") }
        static var backupBody: String { tr("settings.backupBody") }
        static var exportLibrary: String { tr("settings.exportLibrary") }
        static var shareExportedLibrary: String { tr("settings.shareExportedLibrary") }
        static var importLibrary: String { tr("settings.importLibrary") }
        static var importLibraryTitle: String { tr("settings.importLibraryTitle") }
        static var importLibraryMessage: String { tr("settings.importLibraryMessage") }
        static var importLibraryConfirm: String { tr("settings.importLibraryConfirm") }
        static var importLibraryFailedTitle: String { tr("settings.importLibraryFailedTitle") }
        static var importLibraryFailedMessage: String { tr("settings.importLibraryFailedMessage") }
        static var privacyTitle: String { tr("settings.privacyTitle") }
        static var privacyLocalTitle: String { tr("settings.privacyLocalTitle") }
        static var privacyLocalBody: String { tr("settings.privacyLocalBody") }
        static var privacyAPIKeysTitle: String { tr("settings.privacyAPIKeysTitle") }
        static var privacyAPIKeysBody: String { tr("settings.privacyAPIKeysBody") }
        static var privacyMediaTitle: String { tr("settings.privacyMediaTitle") }
        static var privacyMediaBody: String { tr("settings.privacyMediaBody") }
        static var privacyNetworkTitle: String { tr("settings.privacyNetworkTitle") }
        static var privacyNetworkBody: String { tr("settings.privacyNetworkBody") }
    }

    enum Empty {
        static var collectionsTitle: String { tr("empty.collectionsTitle") }
        static var collectionsMessage: String { tr("empty.collectionsMessage") }
        static var shelvesTitle: String { tr("empty.shelvesTitle") }
        static var shelvesMessage: String { tr("empty.shelvesMessage") }
        static var piecesTitle: String { tr("empty.piecesTitle") }
        static var piecesMessage: String { tr("empty.piecesMessage") }
        static var searchTitle: String { tr("empty.searchTitle") }
        static var searchMessage: String { tr("empty.searchMessage") }
    }

    enum Detail {
        static var groups: String { tr("detail.groups") }
        static var items: String { tr("detail.items") }
        static var addGroup: String { tr("detail.addGroup") }
        static var addItem: String { tr("detail.addItem") }
        static var empty: String { tr("detail.empty") }
        static var groupName: String { tr("detail.groupName") }
        static var groupSubtitle: String { tr("detail.groupSubtitle") }
        static var newGroupHint: String { tr("detail.newGroupHint") }
    }

    enum CustomMode {
        static var title: String { tr("customMode.title") }
        static var hint: String { tr("customMode.hint") }
        static var shelvesAndPieces: String { tr("customMode.shelvesAndPieces") }
        static var shelvesAndPiecesHint: String { tr("customMode.shelvesAndPiecesHint") }
        static var shelvesOnly: String { tr("customMode.shelvesOnly") }
        static var shelvesOnlyHint: String { tr("customMode.shelvesOnlyHint") }
        static var piecesOnly: String { tr("customMode.piecesOnly") }
        static var piecesOnlyHint: String { tr("customMode.piecesOnlyHint") }
    }

    enum Onboarding {
        static var headline: String { tr("onboarding.headline") }
        static var tagline: String { tr("onboarding.tagline") }
        static var collections: String { tr("onboarding.collections") }
        static var imports: String { tr("onboarding.imports") }
        static var ownership: String { tr("onboarding.ownership") }
        static var start: String { tr("onboarding.start") }
    }

    enum CategoryDetail {
        static var delete: String { tr("categoryDetail.delete") }
        static var deleteTitle: String { tr("categoryDetail.deleteTitle") }
        static var deleteMessage: String { tr("categoryDetail.deleteMessage") }
        static var deleteConfirm: String { tr("categoryDetail.deleteConfirm") }
    }

    enum GroupDetail {
        static var delete: String { tr("groupDetail.delete") }
        static var deleteTitle: String { tr("groupDetail.deleteTitle") }
        static var deleteMessage: String { tr("groupDetail.deleteMessage") }
        static var deleteConfirm: String { tr("groupDetail.deleteConfirm") }
        static var searchPlaceholder: String { tr("groupDetail.searchPlaceholder") }
        static var issueCounter: String { tr("groupDetail.issueCounter") }
    }

    enum ItemEditor {
        static var newItem: String { tr("itemEditor.newItem") }
        static var editItem: String { tr("itemEditor.editItem") }
        static var namePlaceholder: String { tr("itemEditor.namePlaceholder") }
        static var subtitlePlaceholder: String { tr("itemEditor.subtitlePlaceholder") }
        static var notesPlaceholder: String { tr("itemEditor.notesPlaceholder") }
        static var cover: String { tr("itemEditor.cover") }
        static var coverHint: String { tr("itemEditor.coverHint") }
        static var gallery: String { tr("itemEditor.gallery") }
        static var camera: String { tr("itemEditor.camera") }
        static var clearCover: String { tr("itemEditor.clearCover") }
        static var coverURLPlaceholder: String { tr("itemEditor.coverURLPlaceholder") }
    }

    enum ItemDetail {
        static var noNotes: String { tr("itemDetail.noNotes") }
        static var edit: String { tr("itemDetail.edit") }
        static var delete: String { tr("itemDetail.delete") }
        static var deleteTitle: String { tr("itemDetail.deleteTitle") }
        static var deleteMessage: String { tr("itemDetail.deleteMessage") }
    }

    enum ComicVine {
        static var searchTitle: String { tr("comicVine.searchTitle") }
        static var importSeriesTitle: String { tr("comicVine.importSeriesTitle") }
        static var importSeries: String { tr("comicVine.importSeries") }
        static var search: String { tr("comicVine.search") }
        static var searchPlaceholder: String { tr("comicVine.searchPlaceholder") }
        static var seriesSearchPlaceholder: String { tr("comicVine.seriesSearchPlaceholder") }
        static var defaultImportStatus: String { tr("comicVine.defaultImportStatus") }
        static var missingAPIKey: String { tr("comicVine.missingAPIKey") }
        static var invalidURL: String { tr("comicVine.invalidURL") }
        static var requestFailed: String { tr("comicVine.requestFailed") }
    }

    enum TheGamesDB {
        static var searchTitle: String { tr("theGamesDB.searchTitle") }
        static var search: String { tr("theGamesDB.search") }
        static var searchPlaceholder: String { tr("theGamesDB.searchPlaceholder") }
        static var missingAPIKey: String { tr("theGamesDB.missingAPIKey") }
        static var invalidURL: String { tr("theGamesDB.invalidURL") }
        static var requestFailed: String { tr("theGamesDB.requestFailed") }
    }

    enum BookSearch {
        static var searchTitle: String { tr("bookSearch.searchTitle") }
        static var search: String { tr("bookSearch.search") }
        static var searchPlaceholder: String { tr("bookSearch.searchPlaceholder") }
        static var scanBarcode: String { tr("bookSearch.scanBarcode") }
        static var invalidURL: String { tr("bookSearch.invalidURL") }
        static var requestFailed: String { tr("bookSearch.requestFailed") }
    }

    enum Discogs {
        static var searchTitle: String { tr("discogs.searchTitle") }
        static var search: String { tr("discogs.search") }
        static var searchPlaceholder: String { tr("discogs.searchPlaceholder") }
        static var format: String { tr("discogs.format") }
        static var vinyl: String { tr("discogs.vinyl") }
        static var cassette: String { tr("discogs.cassette") }
        static var missingAPIKey: String { tr("discogs.missingAPIKey") }
        static var invalidURL: String { tr("discogs.invalidURL") }
        static var requestFailed: String { tr("discogs.requestFailed") }
    }

    enum TCGdex {
        static var searchTitle: String { tr("tcgdex.searchTitle") }
        static var search: String { tr("tcgdex.search") }
        static var searchPlaceholder: String { tr("tcgdex.searchPlaceholder") }
        static var invalidURL: String { tr("tcgdex.invalidURL") }
        static var requestFailed: String { tr("tcgdex.requestFailed") }
    }

    enum Ownership {
        static var owned: String { tr("ownership.owned") }
        static var missing: String { tr("ownership.missing") }
        static var ownedShort: String { tr("ownership.ownedShort") }
        static var missingShort: String { tr("ownership.missingShort") }
    }

    enum OwnershipFilter {
        static var title: String { tr("ownershipFilter.title") }
        static var all: String { tr("ownershipFilter.all") }
        static var owned: String { tr("ownershipFilter.owned") }
        static var missing: String { tr("ownershipFilter.missing") }
    }

    enum ReadingStatus {
        static var title: String { tr("readingStatus.title") }
        static var unread: String { tr("readingStatus.unread") }
        static var reading: String { tr("readingStatus.reading") }
        static var read: String { tr("readingStatus.read") }
        static var unreadShort: String { tr("readingStatus.unreadShort") }
        static var readingShort: String { tr("readingStatus.readingShort") }
        static var readShort: String { tr("readingStatus.readShort") }
    }

    enum Template {
        static var comicSeries: String { tr("template.comicSeries") }
        static var comicIssues: String { tr("template.comicIssues") }
        static var addComicSeries: String { tr("template.addComicSeries") }
        static var comicSeriesName: String { tr("template.comicSeriesName") }
        static var comicsCategory: String { tr("template.comicsCategory") }
        static var comicsCategoryHint: String { tr("template.comicsCategoryHint") }
        static var bookShelves: String { tr("template.bookShelves") }
        static var books: String { tr("template.books") }
        static var addBookShelf: String { tr("template.addBookShelf") }
        static var bookShelfName: String { tr("template.bookShelfName") }
        static var booksCategory: String { tr("template.booksCategory") }
        static var booksCategoryHint: String { tr("template.booksCategoryHint") }
        static var vinylArtists: String { tr("template.vinylArtists") }
        static var vinylAlbums: String { tr("template.vinylAlbums") }
        static var addVinylArtist: String { tr("template.addVinylArtist") }
        static var vinylArtistName: String { tr("template.vinylArtistName") }
        static var vinylCategory: String { tr("template.vinylCategory") }
        static var vinylCategoryHint: String { tr("template.vinylCategoryHint") }
        static var gamePlatforms: String { tr("template.gamePlatforms") }
        static var games: String { tr("template.games") }
        static var addGamePlatform: String { tr("template.addGamePlatform") }
        static var gamePlatformName: String { tr("template.gamePlatformName") }
        static var gamesCategory: String { tr("template.gamesCategory") }
        static var gamesCategoryHint: String { tr("template.gamesCategoryHint") }
        static var cardSets: String { tr("template.cardSets") }
        static var cards: String { tr("template.cards") }
        static var addCardSet: String { tr("template.addCardSet") }
        static var cardSetName: String { tr("template.cardSetName") }
        static var cardsCategory: String { tr("template.cardsCategory") }
        static var cardsCategoryHint: String { tr("template.cardsCategoryHint") }
        static var collectiblesCategory: String { tr("template.collectiblesCategory") }
        static var collectiblesCategoryHint: String { tr("template.collectiblesCategoryHint") }
        static var customCategory: String { tr("template.customCategory") }
        static var customCategoryHint: String { tr("template.customCategoryHint") }
    }

    enum Seed {
        static var comicsTitle: String { tr("seed.comicsTitle") }
        static var comicsSubtitle: String { tr("seed.comicsSubtitle") }
        static var invincibleTitle: String { tr("seed.invincibleTitle") }
        static var invincibleSubtitle: String { tr("seed.invincibleSubtitle") }
        static var invincibleOneTitle: String { tr("seed.invincibleOneTitle") }
        static var invincibleFourTitle: String { tr("seed.invincibleFourTitle") }
        static var issueSubtitle: String { tr("seed.issueSubtitle") }
        static var wishlistSubtitle: String { tr("seed.wishlistSubtitle") }
        static var sampleNote: String { tr("seed.sampleNote") }
        static var missingSampleNote: String { tr("seed.missingSampleNote") }
        static var vinylTitle: String { tr("seed.vinylTitle") }
        static var vinylSubtitle: String { tr("seed.vinylSubtitle") }
        static var rockTitle: String { tr("seed.rockTitle") }
        static var genreSubtitle: String { tr("seed.genreSubtitle") }
        static var gamesTitle: String { tr("seed.gamesTitle") }
        static var gamesSubtitle: String { tr("seed.gamesSubtitle") }
        static var booksTitle: String { tr("seed.booksTitle") }
        static var booksSubtitle: String { tr("seed.booksSubtitle") }
    }
}

private func tr(_ key: String) -> String {
    let language = AppSettings.selectedLanguage

    guard
        let localeIdentifier = language.localeIdentifier,
        let path = Bundle.main.path(forResource: localeIdentifier, ofType: "lproj"),
        let bundle = Bundle(path: path)
    else {
        return NSLocalizedString(key, comment: "")
    }

    return bundle.localizedString(forKey: key, value: nil, table: nil)
}
