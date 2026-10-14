import Foundation

struct ComicWidgetSnapshot: Hashable {
    let seriesCount: Int
    let totalIssues: Int
    let ownedIssues: Int
    let missingIssues: Int
    let readingIssues: Int
    let readIssues: Int
    let mostIncompleteSeries: ComicSeriesProgress?
    let missingIssueSummary: ComicMissingIssueSummary
    let currentIssue: CollectibleItem?

    var hasIssues: Bool {
        totalIssues > 0
    }

    var ownershipRatio: Double {
        guard totalIssues > 0 else { return 0 }
        return Double(ownedIssues) / Double(totalIssues)
    }

    init(category: CollectionCategory) {
        self.init(groups: category.groups, looseItems: category.items)
    }

    init(group: CollectionGroup) {
        self.init(groups: group.groups.isEmpty ? [group] : group.groups, looseItems: group.items)
    }

    private init(groups: [CollectionGroup], looseItems: [CollectibleItem]) {
        let groupProgress = groups.map { ComicSeriesProgress(group: $0) }
        let allIssues = looseItems + groups.flatMap(\.allItems)
        let owned = allIssues.filter { $0.ownershipStatus == .owned }
        let missing = allIssues.filter { $0.ownershipStatus == .missing }
        let reading = owned.filter { $0.readingStatus == .reading }
        let read = owned.filter { $0.readingStatus == .read }

        seriesCount = groupProgress.count
        totalIssues = allIssues.count
        ownedIssues = owned.count
        missingIssues = missing.count
        readingIssues = reading.count
        readIssues = read.count
        missingIssueSummary = ComicMissingIssueSummary(items: allIssues)
        mostIncompleteSeries = groupProgress
            .filter { $0.missingIssues > 0 }
            .sorted {
                if $0.missingIssues == $1.missingIssues {
                    return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
                return $0.missingIssues > $1.missingIssues
            }
            .first
        currentIssue = reading.sortedByRecentActivity().first
    }
}

struct ComicSeriesProgress: Hashable {
    let title: String
    let totalIssues: Int
    let ownedIssues: Int
    let missingIssues: Int

    var ownershipRatio: Double {
        guard totalIssues > 0 else { return 0 }
        return Double(ownedIssues) / Double(totalIssues)
    }

    init(group: CollectionGroup) {
        let issues = group.allItems
        title = group.title
        totalIssues = issues.count
        ownedIssues = issues.filter { $0.ownershipStatus == .owned }.count
        missingIssues = issues.filter { $0.ownershipStatus == .missing }.count
    }
}
