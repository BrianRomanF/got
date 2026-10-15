import SwiftUI
import WidgetKit

struct BookReadingWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: CollectorWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(String(localized: "reading.title"), systemImage: "bookmark.fill")
                .font(.caption.weight(.black))
                .foregroundStyle(WidgetComicStyle.red)

            if let book = entry.readingBooks.first {
                HStack(alignment: .center, spacing: 10) {
                    bookIcon
                    VStack(alignment: .leading, spacing: 5) {
                        Text(book.title).font(.subheadline.weight(.black)).lineLimit(2)
                        Text(pageDescription(book))
                            .font(.caption2.weight(.bold)).lineLimit(1).minimumScaleFactor(0.75)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                HStack(spacing: 8) {
                    ProgressView(value: book.progress).tint(WidgetComicStyle.green)
                    Text(book.totalPages == nil ? "—" : "\(Int(book.progress * 100))%")
                        .font(.caption.weight(.black))
                }
                Text(String(localized: "reading.update"))
                    .font(.caption2.weight(.bold))
            } else {
                Text(String(localized: "reading.empty"))
                    .font(.subheadline.weight(.black))
                Text(emptyDescription).font(.caption2.weight(.semibold)).lineLimit(3)
                Label(String(localized: "reading.open"), systemImage: "arrow.up.forward.app")
                    .font(.caption.weight(.black))
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(WidgetComicStyle.ink)
        .environment(\.colorScheme, .light)
        .widgetURL(entry.readingBooks.first?.url ?? URL(string: "gotit://reading"))
        .containerBackground(for: .widget) { WidgetComicBackground() }
    }

    private var bookIcon: some View {
        Image(systemName: "book.closed.fill")
            .font(.system(size: family == .systemSmall ? 28 : 34, weight: .black))
            .foregroundStyle(WidgetComicStyle.red)
            .frame(width: family == .systemSmall ? 40 : 52, height: 56)
            .background(WidgetComicStyle.panel, in: RoundedRectangle(cornerRadius: 5))
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(WidgetComicStyle.ink, lineWidth: 2))
            .accessibilityHidden(true)
    }

    private func pageDescription(_ book: ReadingBookWidgetItem) -> String {
        if let total = book.totalPages {
            return String(format: String(localized: "reading.pages"), book.currentPage, total)
        }
        return String(format: String(localized: "reading.page"), book.currentPage)
    }

    private var emptyDescription: String {
        String(localized: "reading.choose")
    }
}
