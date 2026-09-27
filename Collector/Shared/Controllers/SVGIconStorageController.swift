import Foundation

final class SVGIconStorageController {
    static let shared = SVGIconStorageController()

    private let session: URLSession
    private let fileManager: FileManager

    init(session: URLSession = .shared, fileManager: FileManager = .default) {
        self.session = session
        self.fileManager = fileManager
    }

    func saveIcon(from remoteURLString: String, preferredName: String) async -> String? {
        let trimmedURL = remoteURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURL.isEmpty, let remoteURL = URL(string: trimmedURL) else { return nil }

        do {
            let (data, response) = try await session.data(from: remoteURL)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }
            guard let svg = String(data: data, encoding: .utf8), svg.lowercased().contains("<svg") else { return nil }

            let directory = try iconDirectory()
            let filename = "\(sanitizedFilename(preferredName)).svg"
            let fileURL = uniqueFileURL(in: directory, filename: filename)
            try data.write(to: fileURL, options: .atomic)
            return fileURL.path
        } catch {
            return nil
        }
    }

    func saveIcon(fromLocalFile fileURL: URL, preferredName: String) -> String? {
        let shouldStopAccessing = fileURL.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let data = try Data(contentsOf: fileURL)
            guard let svg = String(data: data, encoding: .utf8), svg.lowercased().contains("<svg") else { return nil }

            let directory = try iconDirectory()
            let baseName = preferredName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? fileURL.deletingPathExtension().lastPathComponent
                : preferredName
            let filename = "\(sanitizedFilename(baseName)).svg"
            let destinationURL = uniqueFileURL(in: directory, filename: filename)
            try data.write(to: destinationURL, options: .atomic)
            return destinationURL.path
        } catch {
            return nil
        }
    }

    private func iconDirectory() throws -> URL {
        let applicationSupport = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let directory = applicationSupport
            .appendingPathComponent("imagenes", isDirectory: true)
            .appendingPathComponent("collector", isDirectory: true)
            .appendingPathComponent("icons", isDirectory: true)

        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private func uniqueFileURL(in directory: URL, filename: String) -> URL {
        let baseURL = directory.appendingPathComponent(filename)
        guard fileManager.fileExists(atPath: baseURL.path) else { return baseURL }

        let name = baseURL.deletingPathExtension().lastPathComponent
        return directory.appendingPathComponent("\(name)-\(UUID().uuidString).svg")
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
