//
//  ImageCarouselView.swift
//  Features
//
//  Created by Henry on 7/19/25.
//

import SwiftUI
import PhotosUI

struct ImageCarouselView: View {
    @ObservedObject var viewModel: RecordDetailViewModel
    
    let isExpanded: Bool
    let isEditing: Bool
    
    @State private var isPickerPresented = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    
    private let fullSize: CGFloat = 342
    private let halfSize: CGFloat = 150
    private let itemSpacing: CGFloat = 12
    private let maxImageCount = 4
    
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
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                if images.count > 1 {
                    Text("+\(images.count - 1)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
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
                    .clipShape(RoundedRectangle(cornerRadius: 12))
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
                        isPickerPresented = true
                    }
                }
            }
            .padding(.horizontal, (UIScreen.main.bounds.width - fullSize) / 2)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .frame(height: fullSize)
        .photosPicker(
            isPresented: $isPickerPresented,
            selection: $selectedPhotoItems,
            maxSelectionCount: maxImageCount - images.count,
            matching: .images
        )
        .onChange(of: selectedPhotoItems) { _, newItems in
            viewModel.addImages(from: newItems)
            selectedPhotoItems.removeAll()
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
            .clipShape(RoundedRectangle(cornerRadius: 12))
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
                Text("사진 추가")
            }
            .font(.headline)
            .foregroundColor(.secondary)
            .frame(width: size, height: size)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    ImageCarouselView(viewModel: RecordDetailViewModel(), isExpanded: true, isEditing: true)
}



