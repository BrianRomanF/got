import Foundation

struct ItemMoveDestination: Identifiable, Hashable {
    let id: String
    let groupID: UUID?
    let title: String
    let subtitle: String

    init(groupID: UUID?, title: String, subtitle: String) {
        self.groupID = groupID
        self.id = groupID?.uuidString ?? "root"
        self.title = title
        self.subtitle = subtitle
    }
}
