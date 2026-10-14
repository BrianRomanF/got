import Foundation

enum CloudKitSyncPlanKind: String, Hashable {
    case uploadLocal
    case downloadRemote
    case noChanges
    case conflict
    case merge
}

struct CloudKitSyncPlan: Hashable {
    let kind: CloudKitSyncPlanKind
    let localItemCount: Int
    let remoteItemCount: Int
    let message: String
    let remoteCategories: [CollectionCategory]?
}
