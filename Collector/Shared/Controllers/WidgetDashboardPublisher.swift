import Foundation
import WidgetKit

enum WidgetDashboardPublisher {
    static let appGroupIdentifier = "group.com.brianroman.Collectorappmen"
    static let snapshotKey = "collector.widgetDashboardSnapshot"

    static func publish(categories: [CollectionCategory]) {
        guard FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) != nil else { return }
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else { return }

        let snapshot = WidgetDashboardSnapshot.make(from: categories)

        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: snapshotKey)
        WidgetCenter.shared.reloadAllTimelines()
        guard let album = VinylFavoriteSelection.featuredAlbum(in: categories)?.item else { return }
        Task { @MainActor in
            let assets = await VinylWidgetAssetController.shared.assets(for: album, localCover: snapshot.featuredAlbum?.coverData)
            guard let latestData = defaults.data(forKey: snapshotKey),
                  var latest = try? JSONDecoder().decode(WidgetDashboardSnapshot.self, from: latestData),
                  latest.updatedAt == snapshot.updatedAt, latest.featuredAlbum?.id == album.id else { return }
            let oldCover = latest.featuredAlbum?.coverData
            let cover = oldCover ?? assets.coverData
            let oldTracks = latest.featuredAlbum?.tracks ?? []
            guard oldCover != cover || oldTracks != assets.tracks else { return }
            latest.featuredAlbum?.coverData = cover
            latest.featuredAlbum?.tracks = assets.tracks
            guard let enriched = try? JSONEncoder().encode(latest) else { return }
            defaults.set(enriched, forKey: snapshotKey)
            WidgetCenter.shared.reloadTimelines(ofKind: "VinylCollectorWidget")
        }
    }
}
