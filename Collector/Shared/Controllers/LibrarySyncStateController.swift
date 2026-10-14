import Foundation

final class LibrarySyncStateController: ObservableObject {
    static let shared = LibrarySyncStateController()

    @Published private(set) var state: LibrarySyncState

    private let defaults: UserDefaults
    private let stateKey = "collector.librarySyncState"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let data = defaults.data(forKey: stateKey),
           let savedState = try? JSONDecoder().decode(LibrarySyncState.self, from: data) {
            state = savedState
        } else {
            state = LibrarySyncState()
        }
    }

    func markSyncStarted(operation: LibrarySyncOperation) {
        state.status = .syncing
        state.currentOperation = operation
        state.lastErrorMessage = nil
        persist()
    }

    func markSynced(at date: Date = .now) {
        state.status = .synced
        state.lastSyncAt = date
        state.currentOperation = nil
        state.lastErrorMessage = nil
        state.pendingChangesCount = 0
        persist()
    }

    func markPendingChanges(count: Int) {
        state.status = count > 0 ? .pendingChanges : .synced
        state.pendingChangesCount = max(0, count)
        state.currentOperation = nil
        persist()
    }

    func markOffline() {
        state.status = .offline
        state.currentOperation = nil
        persist()
    }

    func markConflict(message: String? = nil) {
        state.status = .conflict
        state.currentOperation = nil
        state.lastErrorMessage = message
        persist()
    }

    func markFailed(message: String) {
        state.status = .failed
        state.currentOperation = nil
        state.lastErrorMessage = message
        persist()
    }

    func markBackupCreated(at date: Date = .now) {
        state.lastBackupAt = date
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: stateKey)
    }
}
