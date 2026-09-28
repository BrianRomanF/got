import Foundation

struct CollectionCategory: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var subtitle: String
    var symbolName: String
    var svgIconPath: String?
    var svgIconRemoteURL: URL?
    var template: CollectionTemplate
    var customContentMode: CustomCategoryContentMode
    var groups: [CollectionGroup]
    var items: [CollectibleItem]

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case subtitle
        case symbolName
        case svgIconPath
        case svgIconRemoteURL
        case template
        case customContentMode
        case groups
        case items
    }

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        symbolName: String,
        svgIconPath: String? = nil,
        svgIconRemoteURL: URL? = nil,
        template: CollectionTemplate = .custom,
        customContentMode: CustomCategoryContentMode = .shelvesAndPieces,
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
        self.customContentMode = customContentMode
        self.groups = groups
        self.items = items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        symbolName = try container.decode(String.self, forKey: .symbolName)
        svgIconPath = try container.decodeIfPresent(String.self, forKey: .svgIconPath)
        svgIconRemoteURL = try container.decodeIfPresent(URL.self, forKey: .svgIconRemoteURL)
        template = try container.decode(CollectionTemplate.self, forKey: .template)
        customContentMode = try container.decodeIfPresent(CustomCategoryContentMode.self, forKey: .customContentMode) ?? .shelvesAndPieces
        groups = try container.decode([CollectionGroup].self, forKey: .groups)
        items = try container.decode([CollectibleItem].self, forKey: .items)
    }
}

extension CollectionCategory {
    var allowsTopLevelGroups: Bool {
        guard template == .custom else { return true }
        return customContentMode == .shelvesAndPieces || customContentMode == .shelvesOnly
    }

    var allowsTopLevelItems: Bool {
        guard template == .custom else { return !items.isEmpty }
        return customContentMode == .shelvesAndPieces || customContentMode == .piecesOnly
    }
}
