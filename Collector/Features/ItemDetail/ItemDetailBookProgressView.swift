import SwiftUI

struct ItemDetailBookProgressView: View {
    let item: CollectibleItem

    var body: some View {
        if shouldShowProgress {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.BookProgress.title.uppercased().vintageSafe)
                            .font(.caption.weight(.black))
                            .foregroundStyle(ComicTheme.ink.opacity(0.75))

                        Text(progressText)
                            .font(.title3.weight(.black))
                            .foregroundStyle(ComicTheme.ink)
                    }

                    Spacer(minLength: 0)

                    Text("\(item.bookProgressPercent)%")
                        .font(ComicTheme.titleFont)
                        .foregroundStyle(ComicTheme.ink)
                        .minimumScaleFactor(0.7)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(ComicTheme.paper)
                        Capsule()
                            .fill(ComicTheme.green)
                            .frame(width: item.bookProgressRatio > 0 ? max(8, proxy.size.width * item.bookProgressRatio) : 0)
                    }
                }
                .frame(height: 12)
                .overlay(
                    Capsule()
                        .stroke(ComicTheme.ink, lineWidth: 2)
                )

                if !dateRows.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(dateRows, id: \.title) { row in
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text(row.title.uppercased().vintageSafe)
                                    .font(.caption.weight(.black))
                                    .foregroundStyle(ComicTheme.red)

                                Text(row.value)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(ComicTheme.ink.opacity(0.78))
                            }
                        }
                    }
                }
            }
            .padding(16)
            .comicPanel(fill: ComicTheme.yellow)
        }
    }

    private var shouldShowProgress: Bool {
        item.readingStatus == .reading
            || item.bookCurrentPage != nil
            || item.bookTotalPages != nil
            || item.bookStartedAt != nil
            || item.bookFinishedAt != nil
    }

    private var progressText: String {
        if let currentPage = item.bookCurrentPage, let totalPages = item.bookTotalPages {
            return String(format: L10n.BookProgress.pagesRead, currentPage, totalPages)
        }

        if let currentPage = item.bookCurrentPage {
            return String(format: L10n.BookProgress.currentPage, currentPage)
        }

        if let totalPages = item.bookTotalPages {
            return String(format: L10n.BookProgress.totalPages, totalPages)
        }

        return L10n.BookProgress.noPages
    }

    private var dateRows: [(title: String, value: String)] {
        var rows: [(String, String)] = []
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        if let startedAt = item.bookStartedAt {
            rows.append((L10n.BookProgress.startedAt, formatter.string(from: startedAt)))
        }

        if let finishedAt = item.bookFinishedAt {
            rows.append((L10n.BookProgress.finishedAt, formatter.string(from: finishedAt)))
        }

        return rows
    }
}
