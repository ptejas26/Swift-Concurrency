//
//  PhotoPickerView.swift
//  Lesson 17-PhotoPicker
//
//  Created by Tejas Patelia on 2024-05-20.
//

import SwiftUI
import PhotosUI

class PhotoPickerViewModel: ObservableObject {

    @MainActor @Published var selectedImage: UIImage? = nil
    @Published var selectedItem: PhotosPickerItem? = nil {
        didSet {
            getSelectedPhoto(for: selectedItem)
        }
    }

    @Published var selectedImages: [UIImage] = []
    @Published var selectedItems: [PhotosPickerItem] = [] {
        didSet {
            getSelectedPhotos(for: selectedItems)
        }
    }


    func getSelectedPhoto(for selection: PhotosPickerItem?) {
        Task {
            guard let selectedItem = selection else { return }
            if let data = try? await selectedItem.loadTransferable(type: Data.self) {
                await MainActor.run {
                    selectedImage = UIImage(data: data)
                }
            }
        }
    }

    func getSelectedPhotos(for selections: [PhotosPickerItem]?) {
        Task {
            var images: [UIImage] = []
            guard let selectedItems = selections else { return }

            for image in selectedItems {
                if let data = try? await image.loadTransferable(type: Data.self) {
                    if let image = UIImage(data: data) {
                        images.append(image)
                    }
                }
            }
            selectedImages = images
        }
    }
}

struct PhotoPickerView: View {

    @StateObject private var viewModel = PhotoPickerViewModel()
    var body: some View {
        VStack {
            Text("Photo Selection App")
                .font(.headline)
            Spacer()
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .cornerRadius(20)
            }

            PhotosPicker(selection: $viewModel.selectedItem) {
                Text("Select Photo from Lib")
            }
            .padding()

            if !viewModel.selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .cornerRadius(20)
                        }
                    }
                }
            }

            PhotosPicker(selection: $viewModel.selectedItems) {
                Text("Select Photos from Lib")
            }
            .padding()
            Spacer()
        }
        .padding()
    }
}

#Preview {
    PhotoPickerView()
}
