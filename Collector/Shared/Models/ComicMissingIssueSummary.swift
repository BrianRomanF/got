import Foundation

struct ComicMissingIssueSummary: Hashable {
    let missingNumbers: [Int]

    var missingCount: Int {
        missingNumbers.count
    }

    var displayText: String {
        guard !missingNumbers.isEmpty else { return L10n.ComicMissingIssues.none }

        return ranges
            .map { range in
                range.lowerBound == range.upperBound ? "#\(range.lowerBound)" : "#\(range.lowerBound)-#\(range.upperBound)"
            }
            .joined(separator: ", ")
    }

    init(items: [CollectibleItem]) {
        let numberedItems = items.compactMap { item -> (number: Int, item: CollectibleItem)? in
            guard let number = item.comicIssueNumber else { return nil }
            return (number, item)
        }

        let ownedNumbers = Set(numberedItems.filter { $0.item.ownershipStatus == .owned }.map(\.number))
        let missingNumbers = numberedItems
            .filter { $0.item.ownershipStatus == .missing }
            .map(\.number)

        self.missingNumbers = Array(Set(missingNumbers).subtracting(ownedNumbers)).sorted()
    }

    private var ranges: [ClosedRange<Int>] {
        guard let first = missingNumbers.first else { return [] }

        var ranges: [ClosedRange<Int>] = []
        var start = first
        var previous = first

        for number in missingNumbers.dropFirst() {
            if number == previous + 1 {
                previous = number
                continue
            }

            ranges.append(start...previous)
            start = number
            previous = number
        }

        ranges.append(start...previous)
        return ranges
    }
}

extension CollectibleItem {
    var comicIssueNumber: Int? {
        if let number = issueNumber(from: subtitle) {
            return number
        }

        return issueNumber(from: title)
    }

    private func issueNumber(from value: String) -> Int? {
        guard let match = value.range(of: #"#\s*([0-9]+)(?![.0-9])"#, options: .regularExpression) else {
            return nil
        }

        let rawMatch = String(value[match])
        let digits = rawMatch.filter(\.isNumber)
        return Int(digits)
    }
}
