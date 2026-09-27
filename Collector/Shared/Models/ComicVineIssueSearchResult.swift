import Foundation

struct ComicVineIssueSearchResult: Identifiable, Hashable {
    let id: Int
    let name: String
    let issueNumber: String
    let volumeName: String
    let coverDate: String?
    let storeDate: String?
    let imageURL: URL?
    let siteURL: URL?

    var displayTitle: String {
        let issuePrefix = issueNumber.isEmpty ? volumeName : "\(volumeName) #\(issueNumber)"

        if name.isEmpty || name == issuePrefix {
            return issuePrefix
        }

        return "\(issuePrefix): \(name)"
    }

    var displaySubtitle: String {
        let issueText = issueNumber.isEmpty ? volumeName : "\(volumeName) #\(issueNumber)"

        if let coverDate, !coverDate.isEmpty {
            return "\(issueText) - \(coverDate)"
        }

        return issueText
    }
}
