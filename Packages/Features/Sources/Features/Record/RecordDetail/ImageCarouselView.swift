//
//  ImageCarouselView.swift
//  Features
//
//  Created by Henry on 7/19/25.
//

import SwiftUI
import PhotosUI
import DesignSystem

struct ImageCarouselView: View {
    @ObservedObject var viewModel: RecordDetailViewModel
    @StateObject private var albumViewModel = CustomAlbumViewModel()
    
    let isExpanded: Bool
    let isEditing: Bool
    
    private let fullSize: CGFloat = 342
    private let halfSize: CGFloat = 150
    private let itemSpacing: CGFloat = 12
    private let maxImageCount = 4
    
    @State private var isCustomAlbumPresented = false
    
    // MARK: - Body
    
    var body: some View {
        if let detail = viewModel.detail {
            ZStack {
                collapsedView(images: detail.images)
                    .opacity(isExpanded ? 0 : 1)
                
                expandedView(images: detail.images)
                    .opacity(isExpanded ? 1 : 0)
            }
            .frame(height: isExpanded ? fullSize : halfSize)
        }
    }
    
    // MARK: - Collapsed & Expanded Subviews
    
    private func collapsedView(images: [UIImage]) -> some View {
        ZStack(alignment: .bottomTrailing) {
            if let firstImage = images.first {
                Image(uiImage: firstImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: halfSize, height: halfSize)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                if images.count > 1 {
                    Text("+\(images.count - 1)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignSystem.Color.Gray_white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background {
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule().stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                                )
                        }
                        .clipShape(Capsule())
                        .padding(8)
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: halfSize)
    }
    
    private func expandedView(images: [UIImage]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: itemSpacing) {
                ForEach(images, id: \.self) { image in
                    ImageItemView(
                        image: image,
                        size: fullSize,
                        isEditing: isEditing
                    ) { withAnimation {
                        viewModel.deleteImage(image)
                    }
                    }
                }
                
                if isEditing && images.count < maxImageCount {
                    AddPhotoButton(size: fullSize) {
                        albumViewModel.clearSelectedAssets()
                        isCustomAlbumPresented = true
                    }
                }
            }
            .padding(.horizontal, (UIScreen.main.bounds.width - fullSize) / 2)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .frame(height: fullSize)
        .fullScreenCover(isPresented: $isCustomAlbumPresented) {
            CustomAlbumView(viewModel: albumViewModel)
        }
        .onAppear {
            viewModel.subscribeToAlbumEvents(albumViewModel: albumViewModel)
        }
    }
}

// MARK: - Subviews

struct ImageItemView: View {
    let image: UIImage
    let size: CGFloat
    let isEditing: Bool
    let deleteAction: () -> Void
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(alignment: .topTrailing) {
                if isEditing {
                    Button(action: deleteAction) {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .black.opacity(0.6))
                            .font(.title2)
                            .padding(12)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(8)
                }
            }
    }
}

struct AddPhotoButton: View {
    let size: CGFloat
    let addAction: () -> Void
    
    var body: some View {
        Button(action: addAction) {
            VStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 54, weight: .regular))
                    .foregroundColor(DesignSystem.Color.Gray_IC)
                Text("사진 추가")
                    .font(DesignSystem.Font.Title2.medium)
                    .foregroundColor(DesignSystem.Color.Gray_Text)
            }
            .font(.headline)
            .frame(width: size, height: size)
            .background(DesignSystem.Color.Gray_BG)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    ImageCarouselView(viewModel: RecordDetailViewModel(), isExpanded: true, isEditing: true)
}



