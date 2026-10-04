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
    var bookRating: Int?
    var bookProtagonist: String?
    var bookSeries: String?
    var bookEdition: String?
    var bookFormat: BookOwnershipFormat?
    var templateDetails: [String: String]?
    var ownershipStatus: ItemOwnershipStatus
    var readingStatus: ReadingStatus?
    var createdAt: Date

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
        bookRating: Int? = nil,
        bookProtagonist: String? = nil,
        bookSeries: String? = nil,
        bookEdition: String? = nil,
        bookFormat: BookOwnershipFormat? = nil,
        templateDetails: [String: String]? = nil,
        ownershipStatus: ItemOwnershipStatus = .owned,
        readingStatus: ReadingStatus? = nil,
        createdAt: Date = .now
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
        self.bookRating = bookRating
        self.bookProtagonist = bookProtagonist
        self.bookSeries = bookSeries
        self.bookEdition = bookEdition
        self.bookFormat = bookFormat
        self.templateDetails = templateDetails
        self.ownershipStatus = ownershipStatus
        self.readingStatus = readingStatus
        self.createdAt = createdAt
    }
}
