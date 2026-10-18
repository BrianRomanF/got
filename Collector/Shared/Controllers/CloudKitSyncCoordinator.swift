import CloudKit
import Foundation

@MainActor
final class CloudKitSyncCoordinator: ObservableObject {
    @Published private(set) var accountStatus: CKAccountStatus = .couldNotDetermine
    @Published private(set) var isCheckingAccount = false
    @Published private(set) var lastErrorMessage: String?

    private let store: CloudKitLibraryStore
    private let syncStateController: LibrarySyncStateController

    init(
        store: CloudKitLibraryStore = .shared,
        syncStateController: LibrarySyncStateController
    ) {
        self.store = store
        self.syncStateController = syncStateController
    }

    func refreshAccountStatus() async {
        isCheckingAccount = true
        lastErrorMessage = nil

        do {
            accountStatus = try await store.accountStatus()
            if accountStatus == .available {
                syncStateController.markPendingChanges(count: syncStateController.state.pendingChangesCount)
            } else {
                syncStateController.markOffline()
            }
        } catch {
            lastErrorMessage = error.localizedDescription
            syncStateController.markFailed(message: error.localizedDescription)
        }

        isCheckingAccount = false
    }

    func downloadCategories() async throws -> [CollectionCategory] {
        syncStateController.markSyncStarted(operation: .download)
        do {
            let categories = try await store.loadCategories()
            syncStateController.markSynced()
            return categories
        } catch {
            syncStateController.markFailed(message: error.localizedDescription)
            throw error
        }
    }

    func uploadCategories(_ categories: [CollectionCategory]) async throws {
        syncStateController.markSyncStarted(operation: .upload)
        do {
            try await store.saveCategories(categories)
            syncStateController.markSynced()
        } catch {
            syncStateController.markFailed(message: error.localizedDescription)
            throw error
        }
    }

    func synchronizeAutomatically(localCategories: [CollectionCategory]) async {
        guard accountStatus == .available else { return }

        do {
            let plan = try await preparePlan(localCategories: localCategories)
            switch plan.kind {
            case .uploadLocal:
                try await execute(plan: plan, decision: .uploadLocal, localCategories: localCategories)
            case .noChanges:
                syncStateController.markSynced()
            case .downloadRemote, .conflict, .merge:
                syncStateController.markConflict(message: plan.message)
            }
        } catch {
            syncStateController.markFailed(message: error.localizedDescription)
        }
    }

    func preparePlan(localCategories: [CollectionCategory]) async throws -> CloudKitSyncPlan {
        let localCount = localCategories.reduce(0) { $0 + $1.allItems.count }

        do {
            let remoteCategories = try await store.loadCategories()
            let remoteCount = remoteCategories.reduce(0) { $0 + $1.allItems.count }

            if remoteCategories == localCategories {
                return CloudKitSyncPlan(
                    kind: .noChanges,
                    localItemCount: localCount,
                    remoteItemCount: remoteCount,
                    message: "The devices already have the same library.",
                    remoteCategories: remoteCategories
                )
            }

            if localCategories.isEmpty, !remoteCategories.isEmpty {
                return CloudKitSyncPlan(
                    kind: .downloadRemote,
                    localItemCount: 0,
                    remoteItemCount: remoteCount,
                    message: "The iCloud library can be downloaded to this device.",
                    remoteCategories: remoteCategories
                )
            }

            return CloudKitSyncPlan(
                kind: .conflict,
                localItemCount: localCount,
                remoteItemCount: remoteCount,
                message: "Both local and iCloud libraries contain changes.",
                remoteCategories: remoteCategories
            )
        } catch let error as CKError where error.code == .unknownItem {
            return CloudKitSyncPlan(
                kind: localCategories.isEmpty ? .noChanges : .uploadLocal,
                localItemCount: localCount,
                remoteItemCount: 0,
                message: "There is no iCloud library yet.",
                remoteCategories: nil
            )
        }
    }

    func execute(
        plan: CloudKitSyncPlan,
        decision: CloudKitSyncPlanKind,
        localCategories: [CollectionCategory]
    ) async throws -> [CollectionCategory]? {
        let isAllowedDecision = plan.kind == decision
            || plan.kind == .conflict && (decision == .uploadLocal || decision == .downloadRemote || decision == .merge)
        guard isAllowedDecision else {
            syncStateController.markConflict(message: plan.message)
            throw CloudKitLibraryError.invalidSnapshot
        }

        switch decision {
        case .uploadLocal:
            try await uploadCategories(localCategories)
            return nil
        case .downloadRemote:
            guard let remoteCategories = plan.remoteCategories else {
                throw CloudKitLibraryError.recordNotFound
            }
            syncStateController.markSyncStarted(operation: .download)
            syncStateController.markSynced()
            return remoteCategories
        case .noChanges:
            syncStateController.markSynced()
            return nil
        case .merge:
            guard let remoteCategories = plan.remoteCategories else {
                throw CloudKitLibraryError.recordNotFound
            }
            let mergedCategories = merge(local: localCategories, remote: remoteCategories)
            try await uploadCategories(mergedCategories)
            return mergedCategories
        case .conflict:
            syncStateController.markConflict(message: plan.message)
            throw CloudKitLibraryError.invalidSnapshot
        }
    }

    private func merge(
        local: [CollectionCategory],
        remote: [CollectionCategory]
    ) -> [CollectionCategory] {
        var merged = remote

        for localCategory in local {
            guard let index = merged.firstIndex(where: { $0.id == localCategory.id }) else {
                merged.append(localCategory)
                continue
            }

            var category = merged[index]
            category.title = localCategory.title
            category.subtitle = localCategory.subtitle
            category.symbolName = localCategory.symbolName
            category.svgIconPath = localCategory.svgIconPath
            category.svgIconRemoteURL = localCategory.svgIconRemoteURL
            category.template = localCategory.template
            category.customContentMode = localCategory.customContentMode
            category.items = mergeItems(local: localCategory.items, remote: category.items)
            category.groups = mergeGroups(local: localCategory.groups, remote: category.groups)
            merged[index] = category
        }

        return merged
    }

    private func mergeGroups(
        local: [CollectionGroup],
        remote: [CollectionGroup]
    ) -> [CollectionGroup] {
        var merged = remote

        for localGroup in local {
            guard let index = merged.firstIndex(where: { $0.id == localGroup.id }) else {
                merged.append(localGroup)
                continue
            }

            var group = merged[index]
            group.title = localGroup.title
            group.subtitle = localGroup.subtitle
            group.items = mergeItems(local: localGroup.items, remote: group.items)
            group.groups = mergeGroups(local: localGroup.groups, remote: group.groups)
            merged[index] = group
        }

        return merged
    }

    private func mergeItems(
        local: [CollectibleItem],
        remote: [CollectibleItem]
    ) -> [CollectibleItem] {
        var merged = remote

        for localItem in local {
            guard let index = merged.firstIndex(where: { $0.id == localItem.id }) else {
                merged.append(localItem)
                continue
            }

            let remoteItem = merged[index]
            let localDate = localItem.updatedAt ?? localItem.createdAt
            let remoteDate = remoteItem.updatedAt ?? remoteItem.createdAt
            if localDate >= remoteDate {
                merged[index] = localItem
            }
        }

        return merged
    }
}
