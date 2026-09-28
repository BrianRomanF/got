import SwiftUI
import PhotosUI
import UIKit

struct ItemCoverSelector: View {
    @Binding var coverImageData: Data?
    @Binding var coverURLString: String
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isShowingCamera = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.ItemEditor.cover.uppercased().vintageSafe)
                .font(ComicTheme.titleFont)
                .foregroundStyle(ComicTheme.ink)

            CoverImageView(
                title: L10n.ItemEditor.cover,
                ownershipStatus: .owned,
                localImageData: coverImageData,
                localImagePath: nil,
                remoteImageURL: CoverImageURLValidator.directImageURL(from: coverURLString),
                ownedFill: ComicTheme.red,
                placeholderSymbolName: "camera.viewfinder",
                showsTitle: false
            )

            HStack(spacing: 10) {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    ItemCoverSourceButton(systemName: "photo.on.rectangle", title: L10n.ItemEditor.gallery)
                }
                .buttonStyle(.plain)

                Button {
                    isShowingCamera = true
                } label: {
                    ItemCoverSourceButton(systemName: "camera.fill", title: L10n.ItemEditor.camera)
                }
                .buttonStyle(.plain)
                .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                .opacity(UIImagePickerController.isSourceTypeAvailable(.camera) ? 1 : 0.45)
            }

            if coverImageData != nil || !coverURLString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Button {
                    coverImageData = nil
                    coverURLString = ""
                } label: {
                    ItemCoverSourceButton(systemName: "xmark.square.fill", title: L10n.ItemEditor.clearCover)
                }
                .buttonStyle(.plain)
            }

            TextField("", text: $coverURLString, prompt: Text(L10n.ItemEditor.coverURLPlaceholder).foregroundStyle(ComicTheme.ink.opacity(0.45)))
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .comicTextField()

            Text(L10n.ItemEditor.coverHint)
                .font(.caption.weight(.bold))
                .foregroundStyle(ComicTheme.ink.opacity(0.68))
        }
        .padding(16)
        .comicPanel(fill: ComicTheme.panel)
        .sheet(isPresented: $isShowingCamera) {
            CameraPickerView { data in
                coverImageData = data
                coverURLString = ""
            }
            .ignoresSafeArea()
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                guard
                    let data = try? await newItem?.loadTransferable(type: Data.self),
                    let optimizedData = CoverImageDataProcessor.optimizedJPEGData(from: data)
                else {
                    return
                }

                coverImageData = optimizedData
                coverURLString = ""
            }
        }
    }
}
