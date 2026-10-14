import Foundation

protocol LibraryRepository {
    func loadCategories() -> [CollectionCategory]
    func loadCategories(from fileURL: URL) throws -> [CollectionCategory]
    func saveCategories(_ categories: [CollectionCategory])
    func exportCategories(_ categories: [CollectionCategory]) -> URL?
}

final class LocalLibraryRepository: LibraryRepository {
    private let persistence: CollectionLibraryPersistenceController

    init(persistence: CollectionLibraryPersistenceController = .shared) {
        self.persistence = persistence
    }

    func loadCategories() -> [CollectionCategory] {
        persistence.loadCategories() ?? []
    }

    func loadCategories(from fileURL: URL) throws -> [CollectionCategory] {
        try persistence.loadCategories(from: fileURL)
    }

    func saveCategories(_ categories: [CollectionCategory]) {
        persistence.saveCategories(categories)
    }

    func exportCategories(_ categories: [CollectionCategory]) -> URL? {
        persistence.exportCategories(categories)
    }
}
