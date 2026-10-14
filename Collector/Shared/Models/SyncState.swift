import Foundation

enum LibrarySyncStatus: String, Codable, Hashable {
    case unavailable
    case idle
    case syncing
    case synced
    case pendingChanges
    case offline
    case conflict
    case failed

    var isActive: Bool {
        self == .syncing
    }
}

enum LibrarySyncOperation: String, Codable, Hashable {
    case automatic
    case manual
    case upload
    case download
    case merge
}

struct LibrarySyncState: Codable, Hashable {
    var status: LibrarySyncStatus = .unavailable
    var lastSyncAt: Date?
    var lastErrorMessage: String?
    var pendingChangesCount = 0
    var currentOperation: LibrarySyncOperation?
    var lastBackupAt: Date?
}
