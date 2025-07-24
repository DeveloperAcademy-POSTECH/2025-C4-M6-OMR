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
    @State private var showCustomAlbum = false
    
    public init(viewModel: RecordSaveSheetViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            if viewModel.didSelectFromLibrary {
                selectedPhotosGrid
            } else {
                RecentPhotosView(viewModel: viewModel)
            }
            
            photoLibraryButton
        }
    }
    
    // MARK: - Composed Subviews
    
    @ViewBuilder
    private var selectedPhotosGrid: some View {
        GeometryReader { geo in
            let totalImageWidth = geo.size.width - (4 * 3)
            let photoSize = totalImageWidth / 4
            
            HStack(spacing: 4) {
                ForEach(viewModel.selectedImages, id: \.self) { image in
                    SelectedPhotoView(
                        image: image,
                        deleteAction: {
                            viewModel.removeSelectedImage(image)
                        },
                        size: photoSize
                    )
                }
            }
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .frame(height: 100)
    }
    
    @ViewBuilder
    private var photoLibraryButton: some View {
        Button(action: {
            // CustomAlbumView 띄우기 전 전체 사진 호출
            viewModel.prepareForAllPhotos()
            showCustomAlbum = true
        }) {
            HStack {
                Image(systemName: "photo.on.rectangle.angled")
                Text("사진 라이브러리")
                Spacer()
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(Color(red: 0.1, green: 0.12, blue: 0.15))
            .background(.clear)
        }
        .fullScreenCover(isPresented: $showCustomAlbum) {
            CustomAlbumView(viewModel: viewModel)
        }
    }
}
