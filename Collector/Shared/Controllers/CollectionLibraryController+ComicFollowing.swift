import Foundation

extension CollectionLibraryController {
    func toggleFollowingComicSeries(groupID: UUID, categoryID: UUID) {
        guard category(with: categoryID)?.template == .comics,
              let group = group(with: groupID, in: categoryID) else { return }
        setComicFollowing(groupID: group.isFollowing == true ? nil : groupID, categoryID: categoryID)
    }
}
