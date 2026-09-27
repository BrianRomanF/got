import Foundation

final class CollectionLibraryPersistenceController {
    static let shared = CollectionLibraryPersistenceController()

    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func loadCategories() -> [CollectionCategory]? {
        do {
            let url = try libraryURL()
            guard fileManager.fileExists(atPath: url.path) else { return nil }
            return try loadCategories(from: url)
        } catch {
            return nil
        }
    }

    func loadCategories(from fileURL: URL) throws -> [CollectionCategory] {
        let shouldStopAccessing = fileURL.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([CollectionCategory].self, from: data)
    }

    func saveCategories(_ categories: [CollectionCategory]) {
        do {
            let url = try libraryURL()
            let data = try encodedData(for: categories)
            try data.write(to: url, options: .atomic)
        } catch {
            return
        }
    }

    func exportCategories(_ categories: [CollectionCategory]) -> URL? {
        do {
            let directory = try exportDirectory()
            let fileURL = directory.appendingPathComponent("got-it-library.json")
            let data = try encodedData(for: categories)
            try data.write(to: fileURL, options: .atomic)
            return fileURL
        } catch {
            return nil
        }
    }

    private func encodedData(for categories: [CollectionCategory]) throws -> Data {
        try encoder.encode(categories)
    }

    private func libraryURL() throws -> URL {
        let applicationSupport = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let directory = applicationSupport
            .appendingPathComponent("collector", isDirectory: true)
            .appendingPathComponent("library", isDirectory: true)

        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("collections.json")
    }

    private func exportDirectory() throws -> URL {
        let caches = try fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let directory = caches
            .appendingPathComponent("collector", isDirectory: true)
            .appendingPathComponent("exports", isDirectory: true)

        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}
