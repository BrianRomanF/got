import Foundation

final class LibraryLocalBackupController {
    static let shared = LibraryLocalBackupController()

    private let fileManager: FileManager
    private let encoder: JSONEncoder

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
    }

    func createBackup(for categories: [CollectionCategory]) throws -> LibraryLocalBackup {
        let backupDirectory = try backupsDirectory()
        let backupID = UUID()
        let fileURL = backupDirectory.appendingPathComponent("library-(backupID.uuidString).json")
        let data = try encoder.encode(categories)
        try data.write(to: fileURL, options: .atomic)

        return LibraryLocalBackup(
            id: backupID,
            createdAt: .now,
            fileURL: fileURL,
            itemCount: categories.reduce(0) { $0 + $1.allItems.count }
        )
    }

    func deleteBackup(_ backup: LibraryLocalBackup) {
        try? fileManager.removeItem(at: backup.fileURL)
    }

    private func backupsDirectory() throws -> URL {
        let applicationSupport = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let directory = applicationSupport
            .appendingPathComponent("collector", isDirectory: true)
            .appendingPathComponent("sync-backups", isDirectory: true)

        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}
