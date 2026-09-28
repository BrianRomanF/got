import Foundation

struct TCGdexCardSearchResult: Identifiable, Hashable {
    let id: String
    let name: String
    let localID: String?
    let imageURL: URL?

    var displaySubtitle: String {
        localID.map { "#\($0)" } ?? "TCGdex"
    }
}
