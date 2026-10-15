import Foundation

enum DefaultLibraryCategories {
    static func make() -> [CollectionCategory] {
        let templates: [CollectionTemplate] = [.comics, .games, .vinyl, .books]
        return templates.map { template in
            CollectionCategory(
                title: template.creationTitle,
                subtitle: "",
                symbolName: template.defaultSymbolName,
                template: template
            )
        }
    }
}
