import SwiftUI

struct ItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var libraryController: CollectionLibraryController
    @State private var isEditing = false
    @State private var isEditingNotes = false
    @State private var isConfirmingDelete = false
    @State private var notesDraft = ""
    @State private var currentItemID: UUID
    let categoryID: UUID
    let groupID: UUID?
    let itemID: UUID

    init(categoryID: UUID, groupID: UUID?, itemID: UUID) {
        self.categoryID = categoryID
        self.groupID = groupID
        self.itemID = itemID
        _currentItemID = State(initialValue: itemID)
    }

    var body: some View {
        ZStack {
            HalftoneBackground()

            if let item {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        ItemDetailCoverView(item: item)
                        ItemDetailMetadataView(item: item)
                        if libraryController.category(with: categoryID)?.template == .books {
                            ItemDetailBookDetailsView(item: item)
                        }
                        if let category = libraryController.category(with: categoryID) {
                            ItemDetailTemplateDetailsView(
                                title: L10n.TemplateDetails.title,
                                fields: category.template.detailFields,
                                values: item.templateDetails ?? [:]
                            )
                        }
                        ItemDetailNotesView(notes: item.notes) {
                            notesDraft = item.notes
                            isEditingNotes = true
                        }
                    }
                    .padding(20)
                }
                .gesture(detailSwipeGesture)
            }
        }
        .navigationTitle(item?.title ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    isEditing = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.headline.weight(.black))
                }
                .accessibilityLabel(L10n.ItemDetail.edit)

                Button(role: .destructive) {
                    isConfirmingDelete = true
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.headline.weight(.black))
                }
                .accessibilityLabel(L10n.ItemDetail.delete)
            }
        }
        .sheet(isPresented: $isEditing) {
            if let item, let category = libraryController.category(with: categoryID) {
                ItemEditorView(template: category.template, mode: .edit(item)) { updatedItem in
                    libraryController.updateItem(updatedItem, inCategory: categoryID, groupID: groupID)
                    currentItemID = updatedItem.id
                    isEditing = false
                }
            }
        }
        .sheet(isPresented: $isEditingNotes) {
            ItemDetailNotesEditorSheet(notes: $notesDraft) {
                guard var item else { return }
                item.notes = notesDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                libraryController.updateItem(item, inCategory: categoryID, groupID: groupID)
            }
        }
        .alert(L10n.ItemDetail.deleteTitle, isPresented: $isConfirmingDelete) {
            Button(L10n.Common.cancel, role: .cancel) {}
            Button(L10n.ItemDetail.delete, role: .destructive) {
                libraryController.deleteItem(with: currentItemID, inCategory: categoryID, groupID: groupID)
                dismiss()
            }
        } message: {
            Text(L10n.ItemDetail.deleteMessage)
        }
    }

    private var item: CollectibleItem? {
        libraryController.item(with: currentItemID, inCategory: categoryID, groupID: groupID)
    }

    private var detailSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 45)
            .onEnded { value in
                let width = value.translation.width
                let height = value.translation.height

                if abs(width) > abs(height) {
                    if width < -45 {
                        moveToSibling(offset: 1)
                    } else if width > 45 {
                        moveToSibling(offset: -1)
                    }
                    return
                }

                if height > 70 {
                    dismiss()
                }
            }
    }

    private func moveToSibling(offset: Int) {
        let items = libraryController.items(inCategory: categoryID, groupID: groupID)
        guard let index = items.firstIndex(where: { $0.id == currentItemID }) else { return }

        let nextIndex = index + offset
        guard items.indices.contains(nextIndex) else { return }

        withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
            currentItemID = items[nextIndex].id
        }
    }
}
