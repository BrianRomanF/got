import Foundation

struct WishlistCategorySummary: Identifiable, Hashable {
    let id: UUID
    let title: String
    let sections: [WishlistSection]

    var count: Int {
        sections.reduce(0) { $0 + $1.count }
    }
}
