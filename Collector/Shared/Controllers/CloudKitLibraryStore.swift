import CloudKit
import Foundation

enum CloudKitLibraryError: LocalizedError {
    case accountUnavailable
    case invalidSnapshot
    case recordNotFound

    var errorDescription: String? {
        switch self {
        case .accountUnavailable:
            "iCloud account is unavailable."
        case .invalidSnapshot:
            "The iCloud library snapshot is invalid."
        case .recordNotFound:
            "The iCloud library has not been created yet."
        }
    }
}

actor CloudKitLibraryStore {
    static let shared = CloudKitLibraryStore()

    static let containerIdentifier = "iCloud.com.brianroman.Collectorappmen"
    private static let recordType = "LibrarySnapshot"
    private static let recordName = "current-library"
    private static let snapshotField = "snapshot"
    private static let subscriptionID = "collector-library-changes"

    private let container: CKContainer?
    private let database: CKDatabase?
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(container: CKContainer? = nil) {
        #if LOCAL_DEVICE_BUILD
        let resolvedContainer = container
        #else
        let resolvedContainer: CKContainer? = container ?? CKContainer(identifier: Self.containerIdentifier)
        #endif
        self.container = resolvedContainer
        self.database = resolvedContainer?.privateCloudDatabase

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func accountStatus() async throws -> CKAccountStatus {
        guard let container else { return .noAccount }
        return try await container.accountStatus()
    }

    func ensureLibrarySubscription() async throws {
        guard let database else { throw CloudKitLibraryError.accountUnavailable }
        let subscriptionID = Self.subscriptionID

        do {
            _ = try await database.subscription(for: subscriptionID)
            return
        } catch let error as CKError where error.code == .unknownItem {
            let predicate = NSPredicate(format: "recordID == %@", recordID)
            let subscription = CKQuerySubscription(
                recordType: Self.recordType,
                predicate: predicate,
                subscriptionID: subscriptionID,
                options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
            )
            subscription.notificationInfo = CKSubscription.NotificationInfo()
            subscription.notificationInfo?.shouldSendContentAvailable = true
            _ = try await database.save(subscription)
        }
    }

    func loadCategories() async throws -> [CollectionCategory] {
        guard let database else { throw CloudKitLibraryError.accountUnavailable }
        let record = try await database.record(for: recordID)
        guard let data = record[Self.snapshotField] as? Data else {
            throw CloudKitLibraryError.invalidSnapshot
        }

        return try decoder.decode([CollectionCategory].self, from: data)
    }

    func saveCategories(_ categories: [CollectionCategory]) async throws {
        guard let database else { throw CloudKitLibraryError.accountUnavailable }
        let data = try encoder.encode(categories)
        let record: CKRecord
        do {
            record = try await database.record(for: recordID)
        } catch let error as CKError where error.code == .unknownItem {
            record = CKRecord(recordType: Self.recordType, recordID: recordID)
        }

        record[Self.snapshotField] = data as CKRecordValue
        _ = try await database.save(record)
    }

    func deleteRemoteLibrary() async throws {
        guard let database else { throw CloudKitLibraryError.accountUnavailable }
        _ = try await database.deleteRecord(withID: recordID)
    }

    private var recordID: CKRecord.ID {
        CKRecord.ID(recordName: Self.recordName)
    }
}
