import Foundation

enum GameBacklogStatus: String, CaseIterable, Identifiable, Codable, Hashable {
    case pending
    case playing
    case finished
    case completed
    case abandoned

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .pending:
            L10n.GameBacklogStatus.pending
        case .playing:
            L10n.GameBacklogStatus.playing
        case .finished:
            L10n.GameBacklogStatus.finished
        case .completed:
            L10n.GameBacklogStatus.completed
        case .abandoned:
            L10n.GameBacklogStatus.abandoned
        }
    }

    var isDone: Bool {
        self == .finished || self == .completed
    }
}
