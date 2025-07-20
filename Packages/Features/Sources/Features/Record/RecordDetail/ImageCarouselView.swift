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
    // 현재 모달이 확장된 상태인지 여부
    let isExpanded: Bool
    // 최대 이미지 개수
    let maxImageCount = 4
    // 수정모드 여부
    let isEditing: Bool
    
    private let fullSize: CGFloat = 342
    private let halfSize: CGFloat = 150
    private let itemSpacing: CGFloat = 12
    
    @State private var isPickerPresented = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    
    // MARK: - Collapsed & Expanded Subviews
    private var collapsedView: some View {
        let screenWidth = UIScreen.main.bounds.width
        return ZStack(alignment: .bottomTrailing) {
            if let first = viewModel.selectedImages.first {
                Image(uiImage: first)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: halfSize, height: halfSize)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                if viewModel.selectedImages.count > 1 {
                    Text("+\(viewModel.selectedImages.count - 1)")
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
                    .frame(width: screenWidth, height: halfSize)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .frame(width: screenWidth, height: halfSize)
    }
    
    private var expandedView: some View {
        let screenWidth = UIScreen.main.bounds.width
        let horizontalPadding = (screenWidth - fullSize) / 2
        return ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: itemSpacing) {
                ForEach(viewModel.selectedImages, id: \.self) { image in
                    ImageItemView(
                        image: image,
                        size: fullSize,
                        isEditing: isEditing
                    ) {
                        viewModel.deleteImage(image)
                    }
                }
                if isEditing && viewModel.selectedImages.count < maxImageCount {
                    AddPhotoButton(size: fullSize) {
                        isPickerPresented = true
                    }
                }
            }
            .padding(.horizontal, horizontalPadding)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .frame(width: screenWidth, height: fullSize)
        .photosPicker(
            isPresented: $isPickerPresented,
            selection: $selectedPhotoItems,
            maxSelectionCount: maxImageCount - viewModel.selectedImages.count,
            matching: .images
        )
        .onChange(of: selectedPhotoItems) {
            viewModel.addImages(from: selectedPhotoItems)
            selectedPhotoItems.removeAll()
        }
    }
    
    var body: some View {
        ZStack {
            collapsedView
                .opacity(isExpanded ? 0 : 1)
            expandedView
                .opacity(isExpanded ? 1 : 0)
        }
        .frame(height: isExpanded ? fullSize : halfSize)
        .animation(nil, value: isExpanded)
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
                    Button {
                        deleteAction()
                    } label: {
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



