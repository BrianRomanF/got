import Foundation

struct CollectionCategory: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var subtitle: String
    var symbolName: String
    var svgIconPath: String?
    var svgIconRemoteURL: URL?
    var template: CollectionTemplate
    var groups: [CollectionGroup]
    var items: [CollectibleItem]

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        symbolName: String,
        svgIconPath: String? = nil,
        svgIconRemoteURL: URL? = nil,
        template: CollectionTemplate = .custom,
        groups: [CollectionGroup] = [],
        items: [CollectibleItem] = []
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.symbolName = symbolName
        self.svgIconPath = svgIconPath
        self.svgIconRemoteURL = svgIconRemoteURL
        self.template = template
        self.groups = groups
        self.items = items
    }
}
