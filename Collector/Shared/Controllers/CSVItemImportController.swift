import Foundation

enum CSVItemImportError: Error {
    case missingTitleColumn
}

final class CSVItemImportController {
    func importItems(from fileURL: URL, template: CollectionTemplate) throws -> [CollectibleItem] {
        let shouldStopAccessing = fileURL.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }

        let text = try String(contentsOf: fileURL, encoding: .utf8)
        let rows = parseRows(in: text)
        guard let header = rows.first else { return [] }

        let normalizedHeader = header.map { normalizeKey($0) }
        guard let titleIndex = normalizedHeader.firstIndex(of: "title") else {
            throw CSVItemImportError.missingTitleColumn
        }

        return rows.dropFirst().compactMap { row in
            let title = value(in: row, at: titleIndex)
            guard !title.isEmpty else { return nil }

            return CollectibleItem(
                title: title,
                subtitle: value(in: row, named: "subtitle", header: normalizedHeader),
                notes: value(in: row, named: "notes", header: normalizedHeader),
                templateDetails: nil,
                physicalLocation: optionalValue(in: row, named: "location", header: normalizedHeader),
                tags: tags(from: value(in: row, named: "tags", header: normalizedHeader)),
                ownershipStatus: ownership(from: value(in: row, named: "ownership", header: normalizedHeader)),
                readingStatus: template.supportsReadingStatus ? .unread : nil
            )
        }
    }

    private func parseRows(in text: String) -> [[String]] {
        var rows: [[String]] = []
        var row: [String] = []
        var field = ""
        var isInsideQuotes = false
        var index = text.startIndex

        while index < text.endIndex {
            let character = text[index]
            let nextIndex = text.index(after: index)

            if character == "\"" {
                if isInsideQuotes, nextIndex < text.endIndex, text[nextIndex] == "\"" {
                    field.append("\"")
                    index = text.index(after: nextIndex)
                    continue
                }
                isInsideQuotes.toggle()
            } else if character == "," && !isInsideQuotes {
                row.append(field)
                field = ""
            } else if character.isNewline && !isInsideQuotes {
                row.append(field)
                rows.append(row)
                row = []
                field = ""
            } else {
                field.append(character)
            }

            index = nextIndex
        }

        if !field.isEmpty || !row.isEmpty {
            row.append(field)
            rows.append(row)
        }

        return rows.filter { row in
            row.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        }
    }

    private func value(in row: [String], named name: String, header: [String]) -> String {
        guard let index = header.firstIndex(of: name) else { return "" }
        return value(in: row, at: index)
    }

    private func optionalValue(in row: [String], named name: String, header: [String]) -> String? {
        let trimmed = value(in: row, named: name, header: header)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func value(in row: [String], at index: Int) -> String {
        guard row.indices.contains(index) else { return "" }
        return row[index].trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func tags(from value: String) -> [String] {
        var seen = Set<String>()
        return value
            .split(whereSeparator: { $0 == "," || $0 == ";" })
            .compactMap { rawTag in
                let tag = rawTag.trimmingCharacters(in: .whitespacesAndNewlines)
                let key = tag.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                guard !tag.isEmpty, !seen.contains(key) else { return nil }
                seen.insert(key)
                return tag
            }
    }

    private func ownership(from value: String) -> ItemOwnershipStatus {
        let normalized = normalizeKey(value)
        if ["missing", "faltante", "falta", "wishlist"].contains(normalized) {
            return .missing
        }
        return .owned
    }

    private func normalizeKey(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .lowercased()
    }
}
