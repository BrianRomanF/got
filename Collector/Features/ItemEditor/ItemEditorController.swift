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
    @Published var templateDetails: [String: String] = [:]
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
        templateDetails = item.templateDetails ?? [:]
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
            bookRating: template == .books ? normalizedBookRating : nil,
            bookProtagonist: template == .books ? normalizedBookText(bookProtagonist) : nil,
            bookSeries: template == .books ? normalizedBookText(bookSeries) : nil,
            bookEdition: template == .books ? normalizedBookText(bookEdition) : nil,
            bookFormat: template == .books ? bookFormat : nil,
            templateDetails: normalizedTemplateDetails(for: template),
            ownershipStatus: ownershipStatus,
            readingStatus: template.supportsReadingStatus ? readingStatus : nil,
            createdAt: existingItem?.createdAt ?? .now
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
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
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
