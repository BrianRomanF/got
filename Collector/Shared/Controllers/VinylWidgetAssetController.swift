import CryptoKit
import Foundation

struct VinylWidgetAssets: Codable {
    var coverData: Data?
    var tracks: [VinylTrackWidgetItem]
    var releaseID: Int?
    var refreshedAt: Date
}

actor VinylWidgetAssetController {
    static let shared = VinylWidgetAssetController()
    private var pending: [String: Task<VinylWidgetAssets, Never>] = [:]

    static func cached(for item: CollectibleItem) -> VinylWidgetAssets? {
        guard let url = cacheURL(for: item), let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(VinylWidgetAssets.self, from: data)
    }

    func assets(for item: CollectibleItem, localCover: Data?) async -> VinylWidgetAssets {
        let key = Self.cacheURL(for: item)?.lastPathComponent ?? item.id.uuidString
        if let task = pending[key] { return await task.value }
        let cached = Self.cached(for: item)
        let lifetime: TimeInterval = cached?.tracks.isEmpty == false ? 86_400 : 300
        if var cached, Date().timeIntervalSince(cached.refreshedAt) < lifetime {
            cached.coverData = localCover ?? cached.coverData
            if let url = Self.cacheURL(for: item), let data = try? JSONEncoder().encode(cached) {
                try? data.write(to: url, options: .atomic)
            }
            return cached
        }
        let task = Task { await Self.fetch(item: item, cached: cached, localCover: localCover) }
        pending[key] = task
        let assets = await task.value
        pending[key] = nil
        if let url = Self.cacheURL(for: item), let data = try? JSONEncoder().encode(assets) {
            try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? data.write(to: url, options: .atomic)
        }
        return assets
    }

    private static func cacheURL(for item: CollectibleItem) -> URL? {
        guard let root = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        let identity = [item.id.uuidString, item.title, item.subtitle, item.coverRemoteURL?.absoluteString ?? "",
                        item.discogsReleaseID.map(String.init) ?? "", item.vinylCatalogNumber ?? ""].joined(separator: "|")
        let hash = SHA256.hash(data: Data(identity.utf8)).map { String(format: "%02x", $0) }.joined()
        return root.appendingPathComponent("VinylWidgetAssets", isDirectory: true).appendingPathComponent(hash + ".json")
    }

    private static func fetch(item: CollectibleItem, cached: VinylWidgetAssets?, localCover: Data?) async -> VinylWidgetAssets {
        var assets = cached ?? VinylWidgetAssets(coverData: nil, tracks: [], releaseID: nil, refreshedAt: .distantPast)
        assets.coverData = localCover ?? assets.coverData
        let client = DiscogsAPIClient.shared
        var details: DiscogsReleaseDetails?
        do {
            var releaseID = item.discogsReleaseID ?? assets.releaseID
            if releaseID == nil {
                let format: DiscogsMediaFormat = item.notes.localizedCaseInsensitiveContains("cassette") ? .cassette : .vinyl
                let artist = item.subtitle.components(separatedBy: " - ").first ?? ""
                let results = try await client.searchReleases(query: item.title + " " + artist, format: format)
                releaseID = matchingRelease(for: item, in: results)?.id
            }
            if let releaseID {
                details = try await client.releaseDetails(id: releaseID)
                assets.releaseID = releaseID
                if let details { assets.tracks = details.tracks }
            }
        } catch {
            // Keep previously cached songs and artwork while offline or rate limited.
        }
        if assets.coverData == nil {
            let urls = [item.coverRemoteURL, details?.coverURL].compactMap { $0 }
            for url in urls {
                var request = URLRequest(url: url, timeoutInterval: 15)
                request.setValue("GotItCollector/1.0", forHTTPHeaderField: "User-Agent")
                if let (data, response) = try? await URLSession.shared.data(for: request),
                   (response as? HTTPURLResponse)?.statusCode == 200, data.count <= 10_000_000,
                   let thumbnail = WidgetCoverThumbnail.make(data: data) {
                    assets.coverData = thumbnail
                    break
                }
            }
        }
        assets.refreshedAt = .now
        return assets
    }

    static func matchingRelease(for item: CollectibleItem, in results: [DiscogsSearchResult]) -> DiscogsSearchResult? {
        let title = normalized(item.title)
        return results.first { result in
            guard normalized(result.title) == title else { return false }
            if let catalog = item.vinylCatalogNumber, !catalog.isEmpty {
                guard let candidate = result.catalogNumber else { return false }
                return normalized(catalog) == normalized(candidate)
            }
            guard let artist = result.artist, !artist.isEmpty else { return false }
            let subtitle = normalized(item.subtitle)
            let name = normalized(artist)
            return subtitle == name || subtitle.hasPrefix(name + " - ")
        }
    }

    private static func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
    }
}
