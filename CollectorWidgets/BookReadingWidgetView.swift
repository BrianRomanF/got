import SwiftUI
import WidgetKit

struct BookReadingWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: CollectorWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(String(localized: "reading.title"), systemImage: "books.vertical.fill")
                .font(.caption.weight(.black))
                .foregroundStyle(WidgetComicStyle.red)

            if let book = entry.readingBooks.first {
                HStack(alignment: .center, spacing: 10) {
                    if family == .systemSmall { cover(book, width: 38, height: 55) }
                    VStack(alignment: .leading, spacing: 5) {
                        Text(book.title).font(.subheadline.weight(.black)).lineLimit(2)
                        Text(pageDescription(book))
                            .font(.caption2.weight(.bold)).lineLimit(1).minimumScaleFactor(0.75)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    if family == .systemMedium { shelf }
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

    private var shelf: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(Array(entry.readingBooks.prefix(4))) { book in
                    if let url = book.url {
                        Link(destination: url) { cover(book, width: 29, height: 48) }
                            .accessibilityLabel(book.title)
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 3)
            Rectangle().fill(WidgetComicStyle.ink).frame(height: 4)
        }
        .fixedSize()
    }

    private func cover(_ book: ReadingBookWidgetItem, width: CGFloat, height: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 3).fill(WidgetComicStyle.panel)
            if let data = book.coverData, let image = UIImage(data: data) {
                Image(uiImage: image).resizable().scaledToFill()
            } else {
                Text(book.title).font(.system(size: 9, weight: .black, design: .serif))
                    .lineLimit(4).padding(.leading, 6).padding(.trailing, 3)
            }
            Rectangle().fill(WidgetComicStyle.red).frame(width: 4)
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 3))
        .overlay(RoundedRectangle(cornerRadius: 3).stroke(WidgetComicStyle.ink, lineWidth: 1.5))
        .accessibilityLabel(book.title)
    }

    private func pageDescription(_ book: ReadingBookWidgetItem) -> String {
        if let total = book.totalPages {
            return String(format: String(localized: "reading.pages"), book.currentPage, total)
        }
        return String(format: String(localized: "reading.page"), book.currentPage)
    }

    private var emptyDescription: String {
        #if LOCAL_DEVICE_BUILD
        String(localized: "reading.local")
        #else
        String(localized: "reading.choose")
        #endif
    }
}
