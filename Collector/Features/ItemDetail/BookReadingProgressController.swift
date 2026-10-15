import Foundation

@MainActor
final class BookReadingProgressController: ObservableObject {
    @Published var currentPage: String
    @Published var totalPages: String
    @Published var status: ReadingStatus
    private let original: CollectibleItem

    init(item: CollectibleItem) {
        original = item
        currentPage = item.bookCurrentPage.map(String.init) ?? "0"
        totalPages = item.bookTotalPages.map(String.init) ?? ""
        status = item.readingStatus == .read ? .read : .reading
    }

    var updatedItem: CollectibleItem? {
        let pageText = currentPage.trimmingCharacters(in: .whitespacesAndNewlines)
        let totalText = totalPages.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let page = Int(pageText), page >= 0 else { return nil }
        let total = Int(totalText)
        if !totalText.isEmpty {
            guard let total, total > 0, page <= total else { return nil }
        }

        var item = original
        item.bookCurrentPage = status == .read ? (total ?? page) : page
        item.bookTotalPages = total
        item.readingStatus = status == .reading && total != nil && page == total ? .read : status
        if item.readingStatus != .unread, item.bookStartedAt == nil { item.bookStartedAt = .now }
        item.bookFinishedAt = item.readingStatus == .read ? (original.bookFinishedAt ?? .now) : nil
        return item
    }
}
