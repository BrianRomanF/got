import Foundation

struct CollectibleItem: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var subtitle: String
    var notes: String
    var coverImageName: String?
    var coverImageData: Data?
    var coverLocalImagePath: String?
    var coverRemoteURL: URL?
    var comicVineID: Int?
    var comicVineSiteURL: URL?
    var theGamesDBID: Int?
    var gameBacklogStatus: GameBacklogStatus?
    var bookRating: Int?
    var bookProtagonist: String?
    var bookSeries: String?
    var bookEdition: String?
    var bookFormat: BookOwnershipFormat?
    var bookCurrentPage: Int?
    var bookTotalPages: Int?
    var bookStartedAt: Date?
    var bookFinishedAt: Date?
    var vinylMediaCondition: VinylConditionGrade?
    var vinylSleeveCondition: VinylConditionGrade?
    var vinylCatalogNumber: String?
    var templateDetails: [String: String]?
    var physicalLocation: String?
    var tags: [String]
    var ownershipStatus: ItemOwnershipStatus
    var readingStatus: ReadingStatus?
    var createdAt: Date
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case subtitle
        case notes
        case coverImageName
        case coverImageData
        case coverLocalImagePath
        case coverRemoteURL
        case comicVineID
        case comicVineSiteURL
        case theGamesDBID
        case gameBacklogStatus
        case bookRating
        case bookProtagonist
        case bookSeries
        case bookEdition
        case bookFormat
        case bookCurrentPage
        case bookTotalPages
        case bookStartedAt
        case bookFinishedAt
        case vinylMediaCondition
        case vinylSleeveCondition
        case vinylCatalogNumber
        case templateDetails
        case physicalLocation
        case tags
        case ownershipStatus
        case readingStatus
        case createdAt
        case updatedAt
    }

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String = "",
        notes: String = "",
        coverImageName: String? = nil,
        coverImageData: Data? = nil,
        coverLocalImagePath: String? = nil,
        coverRemoteURL: URL? = nil,
        comicVineID: Int? = nil,
        comicVineSiteURL: URL? = nil,
        theGamesDBID: Int? = nil,
        gameBacklogStatus: GameBacklogStatus? = nil,
        bookRating: Int? = nil,
        bookProtagonist: String? = nil,
        bookSeries: String? = nil,
        bookEdition: String? = nil,
        bookFormat: BookOwnershipFormat? = nil,
        bookCurrentPage: Int? = nil,
        bookTotalPages: Int? = nil,
        bookStartedAt: Date? = nil,
        bookFinishedAt: Date? = nil,
        vinylMediaCondition: VinylConditionGrade? = nil,
        vinylSleeveCondition: VinylConditionGrade? = nil,
        vinylCatalogNumber: String? = nil,
        templateDetails: [String: String]? = nil,
        physicalLocation: String? = nil,
        tags: [String] = [],
        ownershipStatus: ItemOwnershipStatus = .owned,
        readingStatus: ReadingStatus? = nil,
        createdAt: Date = .now,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.notes = notes
        self.coverImageName = coverImageName
        self.coverImageData = coverImageData
        self.coverLocalImagePath = coverLocalImagePath
        self.coverRemoteURL = coverRemoteURL
        self.comicVineID = comicVineID
        self.comicVineSiteURL = comicVineSiteURL
        self.theGamesDBID = theGamesDBID
        self.gameBacklogStatus = gameBacklogStatus
        self.bookRating = bookRating
        self.bookProtagonist = bookProtagonist
        self.bookSeries = bookSeries
        self.bookEdition = bookEdition
        self.bookFormat = bookFormat
        self.bookCurrentPage = bookCurrentPage
        self.bookTotalPages = bookTotalPages
        self.bookStartedAt = bookStartedAt
        self.bookFinishedAt = bookFinishedAt
        self.vinylMediaCondition = vinylMediaCondition
        self.vinylSleeveCondition = vinylSleeveCondition
        self.vinylCatalogNumber = vinylCatalogNumber
        self.templateDetails = templateDetails
        self.physicalLocation = physicalLocation
        self.tags = tags
        self.ownershipStatus = ownershipStatus
        self.readingStatus = readingStatus
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        notes = try container.decode(String.self, forKey: .notes)
        coverImageName = try container.decodeIfPresent(String.self, forKey: .coverImageName)
        coverImageData = try container.decodeIfPresent(Data.self, forKey: .coverImageData)
        coverLocalImagePath = try container.decodeIfPresent(String.self, forKey: .coverLocalImagePath)
        coverRemoteURL = try container.decodeIfPresent(URL.self, forKey: .coverRemoteURL)
        comicVineID = try container.decodeIfPresent(Int.self, forKey: .comicVineID)
        comicVineSiteURL = try container.decodeIfPresent(URL.self, forKey: .comicVineSiteURL)
        theGamesDBID = try container.decodeIfPresent(Int.self, forKey: .theGamesDBID)
        gameBacklogStatus = try container.decodeIfPresent(GameBacklogStatus.self, forKey: .gameBacklogStatus)
        bookRating = try container.decodeIfPresent(Int.self, forKey: .bookRating)
        bookProtagonist = try container.decodeIfPresent(String.self, forKey: .bookProtagonist)
        bookSeries = try container.decodeIfPresent(String.self, forKey: .bookSeries)
        bookEdition = try container.decodeIfPresent(String.self, forKey: .bookEdition)
        bookFormat = try container.decodeIfPresent(BookOwnershipFormat.self, forKey: .bookFormat)
        bookCurrentPage = try container.decodeIfPresent(Int.self, forKey: .bookCurrentPage)
        bookTotalPages = try container.decodeIfPresent(Int.self, forKey: .bookTotalPages)
        bookStartedAt = try container.decodeIfPresent(Date.self, forKey: .bookStartedAt)
        bookFinishedAt = try container.decodeIfPresent(Date.self, forKey: .bookFinishedAt)
        vinylMediaCondition = try container.decodeIfPresent(VinylConditionGrade.self, forKey: .vinylMediaCondition)
        vinylSleeveCondition = try container.decodeIfPresent(VinylConditionGrade.self, forKey: .vinylSleeveCondition)
        vinylCatalogNumber = try container.decodeIfPresent(String.self, forKey: .vinylCatalogNumber)
        templateDetails = try container.decodeIfPresent([String: String].self, forKey: .templateDetails)
        physicalLocation = try container.decodeIfPresent(String.self, forKey: .physicalLocation)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        ownershipStatus = try container.decode(ItemOwnershipStatus.self, forKey: .ownershipStatus)
        readingStatus = try container.decodeIfPresent(ReadingStatus.self, forKey: .readingStatus)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
    }
}
