import Foundation

struct ComicVineVolumeSearchResult: Identifiable, Hashable {
    let id: Int
    let name: String
    let startYear: String?
    let publisherName: String?
    let issueCount: Int?
    let imageURL: URL?
    let siteURL: URL?

    var displaySubtitle: String {
        var parts: [String] = []

        if let startYear, !startYear.isEmpty {
            parts.append(startYear)
        }

        if let publisherName, !publisherName.isEmpty {
            parts.append(publisherName)
        }

        if let issueCount {
            parts.append("\(issueCount) \(L10n.Template.comicIssues)")
        }

        return parts.joined(separator: " - ")
    }
}
