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
        self.ownershipStatus = ownershipStatus
        self.readingStatus = readingStatus
        self.createdAt = createdAt
    }
}
