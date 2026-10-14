import Foundation

extension CollectibleItem {
    var bookProgressRatio: Double {
        guard let bookCurrentPage, let bookTotalPages, bookTotalPages > 0 else {
            return readingStatus == .read ? 1 : 0
        }

        return min(1, max(0, Double(bookCurrentPage) / Double(bookTotalPages)))
    }

    var bookProgressPercent: Int {
        Int(bookProgressRatio * 100)
    }
}
