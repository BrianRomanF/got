import Foundation

final class HomeController: ObservableObject {
    @Published var isAddingCategory = false
    @Published var categoryTitle = ""
    @Published var categorySubtitle = ""
    @Published var categorySVGIconURL = ""
    @Published var selectedTemplate: CollectionTemplate = .custom
    @Published var selectedSVGIconPath: String?
    private let iconStorage: SVGIconStorageController

    init(iconStorage: SVGIconStorageController = .shared) {
        self.iconStorage = iconStorage
    }

    func resetForm() {
        categoryTitle = ""
        categorySubtitle = ""
        categorySVGIconURL = ""
        selectedTemplate = .custom
        selectedSVGIconPath = nil
    }

    func prepareForEditing(_ category: CollectionCategory) {
        categoryTitle = category.title
        categorySubtitle = category.subtitle
        categorySVGIconURL = category.svgIconRemoteURL?.absoluteString ?? ""
        selectedTemplate = category.template
        selectedSVGIconPath = category.svgIconPath
    }

    func canSaveCategory() -> Bool {
        !categoryTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func savedSVGIconPath() async -> String? {
        if let selectedSVGIconPath {
            return selectedSVGIconPath
        }

        return await iconStorage.saveIcon(
            from: categorySVGIconURL,
            preferredName: categoryTitle
        )
    }

    func saveSelectedSVGIcon(from fileURL: URL) {
        selectedSVGIconPath = iconStorage.saveIcon(
            fromLocalFile: fileURL,
            preferredName: categoryTitle
        )
    }

    var svgIconRemoteURL: URL? {
        guard selectedSVGIconPath == nil else { return nil }
        return URL(string: categorySVGIconURL.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
