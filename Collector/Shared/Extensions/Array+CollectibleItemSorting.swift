import Foundation

extension Array where Element == CollectibleItem {
    func sorted(using option: ItemSortOption) -> [CollectibleItem] {
        switch option {
        case .newest:
            return sorted { $0.createdAt > $1.createdAt }
        case .number:
            return sortedByIssueNumber()
        case .title:
            return sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .ownedFirst:
            return sorted {
                if $0.ownershipStatus != $1.ownershipStatus {
                    return $0.ownershipStatus == .owned
                }
                return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
        case .missingFirst:
            return sorted {
                if $0.ownershipStatus != $1.ownershipStatus {
                    return $0.ownershipStatus == .missing
                }
                return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
        case .rating:
            return sorted {
                let leftRating = $0.bookRating ?? 0
                let rightRating = $1.bookRating ?? 0
                if leftRating != rightRating {
                    return leftRating > rightRating
                }
                return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
        }
    }

    private func sortedByIssueNumber() -> [CollectibleItem] {
        sorted { left, right in
            let leftNumber = left.issueNumberValue
            let rightNumber = right.issueNumberValue

            switch (leftNumber, rightNumber) {
            case let (leftNumber?, rightNumber?) where leftNumber != rightNumber:
                return leftNumber < rightNumber
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            default:
                return left.title.localizedCaseInsensitiveCompare(right.title) == .orderedAscending
            }
        }
    }
}

private extension CollectibleItem {
    var issueNumberValue: Double? {
        let candidates = [title, subtitle]

        for candidate in candidates {
            if let hashNumber = candidate.firstMatch(for: #"(?<=#)\s*\d+(?:\.\d+)?"#) {
                return Double(hashNumber.trimmingCharacters(in: .whitespacesAndNewlines))
            }

            if let number = candidate.firstMatch(for: #"\b\d+(?:\.\d+)?\b"#) {
                return Double(number)
            }
        }

        return nil
    }
}

private extension String {
    func firstMatch(for pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(startIndex..<endIndex, in: self)
        guard let match = regex.firstMatch(in: self, range: range),
              let matchRange = Range(match.range, in: self) else {
            return nil
        }

        return String(self[matchRange])
    }
}
