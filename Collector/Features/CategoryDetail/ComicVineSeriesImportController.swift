import Foundation

@MainActor
final class ComicVineSeriesImportController: ObservableObject {
    @Published var query = ""
    @Published var defaultOwnershipStatus: ItemOwnershipStatus = .missing
    @Published private(set) var volumes: [ComicVineVolumeSearchResult] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var isSearching = false
    @Published private(set) var isImporting = false

    private let client: ComicVineAPIClient
    private let coverStorage: CoverImageStorageController

    init(client: ComicVineAPIClient = .shared, coverStorage: CoverImageStorageController = .shared) {
        self.client = client
        self.coverStorage = coverStorage
    }

    func searchVolumes() {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }

        isSearching = true
        errorMessage = nil

        Task {
            do {
                volumes = try await client.searchVolumes(query: trimmedQuery)
            } catch {
                volumes = []
                errorMessage = error.localizedDescription
            }

            isSearching = false
        }
    }

    func importGroup(from volume: ComicVineVolumeSearchResult) async -> CollectionGroup? {
        isImporting = true
        errorMessage = nil

        do {
            let issues = try await client.issues(in: volume)
            var items: [CollectibleItem] = []

            for issue in issues {
                items.append(await item(from: issue))
            }

            isImporting = false
            return CollectionGroup(
                title: volume.name,
                subtitle: volume.displaySubtitle,
                items: items
            )
        } catch {
            errorMessage = error.localizedDescription
            isImporting = false
            return nil
        }
    }

    private func item(from issue: ComicVineIssueSearchResult) async -> CollectibleItem {
        let localPath = await coverStorage.saveComicCover(
            from: issue.imageURL,
            preferredName: "\(issue.volumeName)-\(issue.issueNumber)-\(issue.id)"
        )

        return CollectibleItem(
            title: issue.displayTitle,
            subtitle: issue.displaySubtitle,
            notes: "",
            coverLocalImagePath: localPath,
            coverRemoteURL: issue.imageURL,
            comicVineID: issue.id,
            comicVineSiteURL: issue.siteURL,
            ownershipStatus: defaultOwnershipStatus,
            readingStatus: .unread
        )
    }
}
