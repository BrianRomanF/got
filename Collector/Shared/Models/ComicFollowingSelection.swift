import Foundation

struct FollowedComicSeries {
    let categoryID: UUID
    let group: CollectionGroup

    var firstIssue: CollectibleItem? {
        group.allItems.sorted {
            let left = $0.comicIssueNumber ?? Int.max
            let right = $1.comicIssueNumber ?? Int.max
            if left != right { return left < right }
            return $0.title.localizedStandardCompare($1.title) == .orderedAscending
        }.first
    }
}

enum ComicFollowingSelection {
    static func followedSeries(in categories: [CollectionCategory]) -> FollowedComicSeries? {
        for category in categories where category.template == .comics {
            if let group = followedGroup(in: category.groups) {
                return FollowedComicSeries(categoryID: category.id, group: group)
            }
        }
        return nil
    }

    static func selecting(groupID: UUID?, categoryID: UUID, in categories: [CollectionCategory]) -> [CollectionCategory] {
        categories.map { category in
            guard category.template == .comics else { return category }
            var category = category
            category.groups = selecting(groupID: category.id == categoryID ? groupID : nil, in: category.groups)
            return category
        }
    }

    private static func followedGroup(in groups: [CollectionGroup]) -> CollectionGroup? {
        for group in groups {
            if group.isFollowing == true { return group }
            if let nested = followedGroup(in: group.groups) { return nested }
        }
        return nil
    }

    private static func selecting(groupID: UUID?, in groups: [CollectionGroup]) -> [CollectionGroup] {
        groups.map { group in
            var group = group
            group.isFollowing = group.id == groupID ? true : nil
            group.groups = selecting(groupID: groupID, in: group.groups)
            return group
        }
    }
}
