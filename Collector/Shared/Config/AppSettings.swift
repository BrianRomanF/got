import Foundation

enum AppSettings {
    static let selectedLanguageKey = "collector.selectedLanguage"
    static let hasSeenOnboardingKey = "collector.hasSeenOnboarding"
    static let hideOnboardingKey = "collector.hideOnboarding"
    static let comicVineAPIKeyKey = "collector.comicVineAPIKey"
    static let theGamesDBAPIKeyKey = "collector.theGamesDBAPIKey"
    static let googleBooksAPIKeyKey = "collector.googleBooksAPIKey"
    static let discogsConsumerKeyKey = "collector.discogsConsumerKey"
    static let discogsConsumerSecretKey = "collector.discogsConsumerSecret"
    static let defaultOwnershipFilterKey = "collector.defaultOwnershipFilter"
    static let defaultQuickFilterKey = "collector.defaultQuickFilter"
    static let defaultSortOptionKey = "collector.defaultSortOption"
    static let defaultDisplayModeKey = "collector.defaultDisplayMode"

    static var selectedLanguage: AppLanguage {
        get {
            let rawValue = UserDefaults.standard.string(forKey: selectedLanguageKey) ?? AppLanguage.system.rawValue
            return AppLanguage(rawValue: rawValue) ?? .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: selectedLanguageKey)
        }
    }

    static var comicVineAPIKey: String {
        get {
            UserDefaults.standard.string(forKey: comicVineAPIKeyKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: comicVineAPIKeyKey)
        }
    }

    static var theGamesDBAPIKey: String {
        get {
            UserDefaults.standard.string(forKey: theGamesDBAPIKeyKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: theGamesDBAPIKeyKey)
        }
    }

    static var googleBooksAPIKey: String {
        get {
            UserDefaults.standard.string(forKey: googleBooksAPIKeyKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: googleBooksAPIKeyKey)
        }
    }

    static var discogsConsumerKey: String {
        get {
            UserDefaults.standard.string(forKey: discogsConsumerKeyKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: discogsConsumerKeyKey)
        }
    }

    static var discogsConsumerSecret: String {
        get {
            UserDefaults.standard.string(forKey: discogsConsumerSecretKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: discogsConsumerSecretKey)
        }
    }

    static var defaultOwnershipFilter: ItemOwnershipFilter {
        get {
            let rawValue = UserDefaults.standard.string(forKey: defaultOwnershipFilterKey) ?? ItemOwnershipFilter.all.rawValue
            return ItemOwnershipFilter(rawValue: rawValue) ?? .all
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: defaultOwnershipFilterKey)
        }
    }

    static var defaultQuickFilter: ItemQuickFilter {
        get {
            let rawValue = UserDefaults.standard.string(forKey: defaultQuickFilterKey) ?? ItemQuickFilter.all.rawValue
            return ItemQuickFilter(rawValue: rawValue) ?? .all
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: defaultQuickFilterKey)
        }
    }

    static var defaultSortOption: ItemSortOption {
        get {
            let rawValue = UserDefaults.standard.string(forKey: defaultSortOptionKey) ?? ItemSortOption.newest.rawValue
            return ItemSortOption(rawValue: rawValue) ?? .newest
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: defaultSortOptionKey)
        }
    }

    static var defaultDisplayMode: ItemDisplayMode {
        get {
            let rawValue = UserDefaults.standard.string(forKey: defaultDisplayModeKey) ?? ItemDisplayMode.grid.rawValue
            return ItemDisplayMode(rawValue: rawValue) ?? .grid
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: defaultDisplayModeKey)
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english
    case spanish

    var id: String {
        rawValue
    }

    var localeIdentifier: String? {
        switch self {
        case .system:
            return nil
        case .english:
            return "en"
        case .spanish:
            return "es"
        }
    }

    var title: String {
        switch self {
        case .system:
            return L10n.Settings.languageSystem
        case .english:
            return L10n.Settings.languageEnglish
        case .spanish:
            return L10n.Settings.languageSpanish
        }
    }
}
