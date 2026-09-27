import Foundation
import UIKit

final class CoverImageStorageController {
    static let shared = CoverImageStorageController()

    private let session: URLSession
    private let fileManager: FileManager

    init(session: URLSession = .shared, fileManager: FileManager = .default) {
        self.session = session
        self.fileManager = fileManager
    }

    func saveComicCover(from remoteURL: URL?, preferredName: String) async -> String? {
        await saveCover(from: remoteURL, preferredName: preferredName, folderName: "comic")
    }

    func saveGameCover(from remoteURL: URL?, preferredName: String) async -> String? {
        await saveCover(from: remoteURL, preferredName: preferredName, folderName: "game")
    }

    func saveCover(from remoteURL: URL?, preferredName: String, template: CollectionTemplate) async -> String? {
        await saveCover(from: remoteURL, preferredName: preferredName, folderName: folderName(for: template))
    }

    private func saveCover(from remoteURL: URL?, preferredName: String, folderName: String) async -> String? {
        guard let remoteURL else { return nil }

        do {
            let (data, response) = try await session.data(from: remoteURL)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }
            guard let optimizedData = CoverImageDataProcessor.optimizedJPEGData(from: data) else { return nil }

            let directory = try coverDirectory(folderName: folderName)
            let filename = "\(sanitizedFilename(preferredName)).jpg"
            let fileURL = uniqueFileURL(in: directory, filename: filename)
            try optimizedData.write(to: fileURL, options: .atomic)
            return fileURL.path
        } catch {
            return nil
        }
    }

    private func folderName(for template: CollectionTemplate) -> String {
        switch template {
        case .comics:
            "comic"
        case .games:
            "game"
        case .vinyl:
            "vinyl"
        case .books:
            "book"
        case .tradingCards:
            "card"
        case .collectibles:
            "collectible"
        case .custom:
            "custom"
        }
    }

    private func coverDirectory(folderName: String) throws -> URL {
        let applicationSupport = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let directory = applicationSupport
            .appendingPathComponent("imagenes", isDirectory: true)
            .appendingPathComponent("collector", isDirectory: true)
            .appendingPathComponent(folderName, isDirectory: true)

        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private func uniqueFileURL(in directory: URL, filename: String) -> URL {
        let baseURL = directory.appendingPathComponent(filename)
        guard fileManager.fileExists(atPath: baseURL.path) else { return baseURL }

        let name = baseURL.deletingPathExtension().lastPathComponent
        let ext = baseURL.pathExtension
        return directory.appendingPathComponent("\(name)-\(UUID().uuidString).\(ext)")
    }

    private func sanitizedFilename(_ value: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let collapsed = value
            .lowercased()
            .unicodeScalars
            .map { allowed.contains($0) ? Character($0) : "-" }

        let filename = String(collapsed)
            .split(separator: "-")
            .joined(separator: "-")

        return filename.isEmpty ? UUID().uuidString : filename
    }
}
