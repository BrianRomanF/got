import Foundation

@MainActor
final class ItemEditorController: ObservableObject {
    private let existingItem: CollectibleItem?
    private let coverStorage: CoverImageStorageController

    @Published var title = ""
    @Published var subtitle = ""
    @Published var notes = ""
    @Published var ownershipStatus: ItemOwnershipStatus = .owned
    @Published var readingStatus: ReadingStatus = .unread
    @Published var bookRating = 0
    @Published var bookProtagonist = ""
    @Published var bookSeries = ""
    @Published var bookEdition = ""
    @Published var bookFormat: BookOwnershipFormat = .physical
    @Published var bookCurrentPage = ""
    @Published var bookTotalPages = ""
    @Published var hasBookStartedAt = false
    @Published var bookStartedAt: Date = .now
    @Published var hasBookFinishedAt = false
    @Published var bookFinishedAt: Date = .now
    @Published var gameBacklogStatus: GameBacklogStatus = .pending
    @Published var vinylMediaCondition: VinylConditionGrade = .unknown
    @Published var vinylSleeveCondition: VinylConditionGrade = .unknown
    @Published var vinylCatalogNumber = ""
    @Published var templateDetails: [String: String] = [:]
    @Published var physicalLocation = ""
    @Published var tagsText = ""
    @Published var coverImageData: Data?
    @Published var coverURLString = ""
    private var coverLocalImagePath: String?
    private var comicVineID: Int?
    private var comicVineSiteURL: URL?
    private var theGamesDBID: Int?

    init(item: CollectibleItem? = nil, coverStorage: CoverImageStorageController = .shared) {
        self.existingItem = item
        self.coverStorage = coverStorage

        guard let item else { return }

        title = item.title
        subtitle = item.subtitle
        notes = item.notes
        ownershipStatus = item.ownershipStatus
        readingStatus = item.readingStatus ?? .unread
        bookRating = item.bookRating ?? 0
        bookProtagonist = item.bookProtagonist ?? ""
        bookSeries = item.bookSeries ?? ""
        bookEdition = item.bookEdition ?? ""
        bookFormat = item.bookFormat ?? .physical
        bookCurrentPage = item.bookCurrentPage.map(String.init) ?? ""
        bookTotalPages = item.bookTotalPages.map(String.init) ?? ""
        hasBookStartedAt = item.bookStartedAt != nil
        bookStartedAt = item.bookStartedAt ?? .now
        hasBookFinishedAt = item.bookFinishedAt != nil
        bookFinishedAt = item.bookFinishedAt ?? .now
        gameBacklogStatus = item.resolvedGameBacklogStatus
        vinylMediaCondition = item.vinylMediaCondition ?? .unknown
        vinylSleeveCondition = item.vinylSleeveCondition ?? .unknown
        vinylCatalogNumber = item.vinylCatalogNumber ?? ""
        templateDetails = item.templateDetails ?? [:]
        physicalLocation = item.physicalLocation ?? ""
        tagsText = item.tags.joined(separator: ", ")
        coverImageData = item.coverImageData ?? item.coverLocalImagePath.flatMap { try? Data(contentsOf: URL(fileURLWithPath: $0)) }
        coverLocalImagePath = item.coverLocalImagePath
        coverURLString = item.coverRemoteURL?.absoluteString ?? ""
        comicVineID = item.comicVineID
        comicVineSiteURL = item.comicVineSiteURL
        theGamesDBID = item.theGamesDBID
    }

    func canSaveItem() -> Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func makeItem(template: CollectionTemplate) -> CollectibleItem {
        CollectibleItem(
            id: existingItem?.id ?? UUID(),
            title: title,
            subtitle: subtitle,
            notes: notes,
            coverImageData: coverImageData,
            coverLocalImagePath: coverPathForSavedItem,
            coverRemoteURL: normalizedCoverURL,
            comicVineID: comicVineID,
            comicVineSiteURL: comicVineSiteURL,
            theGamesDBID: theGamesDBID,
            gameBacklogStatus: template == .games ? gameBacklogStatus : nil,
            bookRating: template == .books ? normalizedBookRating : nil,
            bookProtagonist: template == .books ? normalizedBookText(bookProtagonist) : nil,
            bookSeries: template == .books ? normalizedBookText(bookSeries) : nil,
            bookEdition: template == .books ? normalizedBookText(bookEdition) : nil,
            bookFormat: template == .books ? bookFormat : nil,
            bookCurrentPage: template == .books ? normalizedBookCurrentPage : nil,
            bookTotalPages: template == .books ? normalizedPositiveInt(bookTotalPages) : nil,
            bookStartedAt: template == .books && hasBookStartedAt ? bookStartedAt : nil,
            bookFinishedAt: template == .books && hasBookFinishedAt ? bookFinishedAt : nil,
            vinylMediaCondition: template == .vinyl ? vinylMediaCondition : nil,
            vinylSleeveCondition: template == .vinyl ? vinylSleeveCondition : nil,
            vinylCatalogNumber: template == .vinyl ? normalizedText(vinylCatalogNumber) : nil,
            templateDetails: normalizedTemplateDetails(for: template),
            physicalLocation: normalizedText(physicalLocation),
            tags: normalizedTags,
            ownershipStatus: ownershipStatus,
            readingStatus: template.supportsReadingStatus ? readingStatus : nil,
            createdAt: existingItem?.createdAt ?? .now,
            updatedAt: existingItem?.updatedAt
        )
    }

    func makeItemAfterPreparingCover(template: CollectionTemplate) async -> CollectibleItem {
        if coverImageData == nil, coverLocalImagePath == nil, let normalizedCoverURL {
            coverLocalImagePath = await coverStorage.saveCover(
                from: normalizedCoverURL,
                preferredName: title,
                template: template
            )
        }

        return makeItem(template: template)
    }

    private var normalizedCoverURL: URL? {
        CoverImageURLValidator.directImageURL(from: coverURLString)
    }

    private var coverPathForSavedItem: String? {
        guard coverImageData == nil else { return nil }
        guard !coverURLString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return coverLocalImagePath
    }

    private var normalizedBookRating: Int? {
        (1...5).contains(bookRating) ? bookRating : nil
    }

    private func normalizedBookText(_ value: String) -> String? {
        normalizedText(value)
    }

    private func normalizedText(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func normalizedPositiveInt(_ value: String) -> Int? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let number = Int(trimmed), number > 0 else { return nil }
        return number
    }

    private var normalizedBookCurrentPage: Int? {
        guard let currentPage = normalizedPositiveInt(bookCurrentPage) else { return nil }
        guard let totalPages = normalizedPositiveInt(bookTotalPages) else { return currentPage }
        return min(currentPage, totalPages)
    }

    private var normalizedTags: [String] {
        var seen = Set<String>()
        return tagsText
            .split(separator: ",")
            .compactMap { rawTag in
                let tag = rawTag.trimmingCharacters(in: .whitespacesAndNewlines)
                let key = tag.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                guard !tag.isEmpty, !seen.contains(key) else { return nil }
                seen.insert(key)
                return tag
            }
    }

    private func normalizedTemplateDetails(for template: CollectionTemplate) -> [String: String]? {
        let allowedKeys = Set(template.detailFields.map(\.key))
        let normalized = templateDetails.reduce(into: [String: String]()) { result, pair in
            guard allowedKeys.contains(pair.key) else { return }
            let trimmed = pair.value.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                result[pair.key] = trimmed
            }
        }

        return normalized.isEmpty ? nil : normalized
    }

    func applyComicVineResult(_ result: ComicVineIssueSearchResult) {
        title = result.displayTitle
        subtitle = result.displaySubtitle
        coverURLString = result.imageURL?.absoluteString ?? ""
        coverImageData = nil
        coverLocalImagePath = nil
        comicVineID = result.id
        comicVineSiteURL = result.siteURL
        theGamesDBID = nil

        Task {
            coverLocalImagePath = await coverStorage.saveComicCover(
                from: result.imageURL,
                preferredName: "\(result.volumeName)-\(result.issueNumber)-\(result.id)"
            )
        }
    }

    func applyTheGamesDBResult(_ result: TheGamesDBGameSearchResult) {
        title = result.title
        subtitle = result.displaySubtitle
        notes = result.overview ?? notes
        coverURLString = result.boxartURL?.absoluteString ?? ""
        coverImageData = nil
        coverLocalImagePath = nil
        comicVineID = nil
        comicVineSiteURL = nil
        theGamesDBID = result.id

        Task {
            coverLocalImagePath = await coverStorage.saveGameCover(
                from: result.boxartURL,
                preferredName: "\(result.title)-\(result.id)"
            )
        }
    }

    func applyBookSearchResult(_ result: BookSearchResult) {
        title = result.title
        subtitle = result.displaySubtitle
        notes = result.description ?? notes
        if let pageCount = result.pageCount {
            bookTotalPages = "\(pageCount)"
        }
        coverURLString = result.coverURL?.absoluteString ?? ""
        coverImageData = nil
        coverLocalImagePath = nil
        comicVineID = nil
        comicVineSiteURL = nil
        theGamesDBID = nil

        Task {
            coverLocalImagePath = await coverStorage.saveCover(
                from: result.coverURL,
                preferredName: "\(result.title)-\(result.id)",
                template: .books
            )
        }
    }

    func applyDiscogsResult(_ result: DiscogsSearchResult) {
        title = result.title
        subtitle = result.displaySubtitle
        notes = result.format.title
        if let year = result.year {
            templateDetails["year"] = year
        }
        if let label = result.label {
            templateDetails["label"] = label
        }
        vinylCatalogNumber = result.catalogNumber ?? vinylCatalogNumber
        coverURLString = result.coverURL?.absoluteString ?? ""
        coverImageData = nil
        coverLocalImagePath = nil
        comicVineID = nil
        comicVineSiteURL = nil
        theGamesDBID = nil

        Task {
            coverLocalImagePath = await coverStorage.saveCover(
                from: result.coverURL,
                preferredName: "\(result.title)-\(result.id)",
                template: .vinyl
            )
        }
    }

    func applyTCGdexResult(_ result: TCGdexCardSearchResult) {
        title = result.name
        subtitle = result.displaySubtitle
        coverURLString = result.imageURL?.absoluteString ?? ""
        coverImageData = nil
        coverLocalImagePath = nil
        comicVineID = nil
        comicVineSiteURL = nil
        theGamesDBID = nil

        Task {
            coverLocalImagePath = await coverStorage.saveCover(
                from: result.imageURL,
                preferredName: "\(result.name)-\(result.id)",
                template: .tradingCards
            )
        }
    }
}
