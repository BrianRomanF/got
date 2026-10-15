import SwiftUI

struct BookReadingProgressSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var library: CollectionLibraryController
    @StateObject private var controller: BookReadingProgressController
    let categoryID: UUID
    let groupID: UUID?
    private let title: String

    init(item: CollectibleItem, categoryID: UUID, groupID: UUID?) {
        _controller = StateObject(wrappedValue: BookReadingProgressController(item: item))
        title = item.title
        self.categoryID = categoryID
        self.groupID = groupID
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HalftoneBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text(title).font(.title2.weight(.black))
                        Text(L10n.BookReading.hint).font(.subheadline)
                        Picker(L10n.ReadingStatus.title, selection: $controller.status) {
                            ForEach(ReadingStatus.allCases) { status in
                                Text(status.title).tag(status)
                            }
                        }
                        .pickerStyle(.segmented)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.BookProgress.currentPagePlaceholder).font(.caption.weight(.bold))
                            TextField(L10n.BookProgress.currentPagePlaceholder, text: $controller.currentPage)
                                .keyboardType(.numberPad).comicTextField()
                            Text(L10n.BookProgress.totalPagesPlaceholder).font(.caption.weight(.bold))
                            TextField(L10n.BookProgress.totalPagesPlaceholder, text: $controller.totalPages)
                                .keyboardType(.numberPad).comicTextField()
                        }
                        if controller.updatedItem == nil {
                            Text(L10n.BookReading.invalidPages).font(.caption.weight(.bold))
                        } else if let item = controller.updatedItem, !library.canTrackReading(item) {
                            Text(L10n.BookReading.limit).font(.caption.weight(.bold))
                        }
                    }
                    .foregroundStyle(ComicTheme.ink)
                    .padding(20)
                }
            }
            .navigationTitle(L10n.BookReading.update)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Common.save) {
                        guard let item = controller.updatedItem, library.canTrackReading(item) else { return }
                        library.updateItem(item, inCategory: categoryID, groupID: groupID)
                        dismiss()
                    }
                    .disabled(controller.updatedItem.map { !library.canTrackReading($0) } ?? true)
                }
            }
        }
    }
}
