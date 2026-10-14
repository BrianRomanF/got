import Foundation

struct LibraryLocalBackup: Identifiable, Codable, Hashable {
    let id: UUID
    let createdAt: Date
    let fileURL: URL
    let itemCount: Int
}
