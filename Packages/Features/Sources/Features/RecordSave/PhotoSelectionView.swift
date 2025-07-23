//
//  PhotoSelectionView.swift
//  Features
//
//  Created by Henry on 7/22/25.
//

import SwiftUI
import PhotosUI
import DesignSystem

public struct PhotoSelectionView: View {
    @ObservedObject var viewModel: RecordSaveSheetViewModel
    
    @State private var isPickerPresented = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    
    public init(viewModel: RecordSaveSheetViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            RecentPhotosView(viewModel: viewModel)
            
            photoLibraryButton
        }
    }
    
    // MARK: - Composed Subviews
    
    @ViewBuilder
    private var photoLibraryButton: some View {
        Button(action: {
            isPickerPresented = true
        }) {
            HStack {
                Image(systemName: "photo.on.rectangle.angled")
                Text("사진 라이브러리")
                Spacer()
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(Color(red: 0.1, green: 0.12, blue: 0.15))
            .padding(.horizontal, 20)
            .background(.clear)
        }
        .photosPicker(
            isPresented: $isPickerPresented,
            selection: $selectedPhotoItems,
            maxSelectionCount: viewModel.maxImageCount - viewModel.selectedImages.count,
            matching: .images
        )
        .onChange(of: selectedPhotoItems) { _, newItems in
            viewModel.addImages(from: newItems)
            selectedPhotoItems = []
        }
    }
}
