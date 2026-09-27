import SwiftUI

struct ItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var libraryController: CollectionLibraryController
    @State private var isEditing = false
    @State private var isConfirmingDelete = false
    let categoryID: UUID
    let groupID: UUID?
    let itemID: UUID

    var body: some View {
        ZStack {
            HalftoneBackground()

            if let item {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        ItemDetailCoverView(item: item)
                        ItemDetailMetadataView(item: item)
                        ItemDetailNotesView(notes: item.notes)
                    }
                    .padding(20)
                }
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
                    isEditing = false
                }
            }
        }
        .alert(L10n.ItemDetail.deleteTitle, isPresented: $isConfirmingDelete) {
            Button(L10n.Common.cancel, role: .cancel) {}
            Button(L10n.ItemDetail.delete, role: .destructive) {
                libraryController.deleteItem(with: itemID, inCategory: categoryID, groupID: groupID)
                dismiss()
            }
        } message: {
            Text(L10n.ItemDetail.deleteMessage)
        }
    }

    private var item: CollectibleItem? {
        libraryController.item(with: itemID, inCategory: categoryID, groupID: groupID)
    }
}
