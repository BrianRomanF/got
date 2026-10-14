import Foundation

extension Array where Element == CollectibleItem {
    func sortedByRecentActivity() -> [CollectibleItem] {
        sorted {
            ($0.updatedAt ?? $0.createdAt) > ($1.updatedAt ?? $1.createdAt)
        }
    }

    func firstTagged(withAnyOf keywords: [String]) -> CollectibleItem? {
        sortedByRecentActivity().first { item in
            item.tags.contains { tag in
                keywords.contains { keyword in
                    tag.range(of: keyword, options: [.caseInsensitive, .diacriticInsensitive]) != nil
                }
            }
        }
    }
}
