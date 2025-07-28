//
//  AlbumGridItemView.swift
//  Features
//
//  Created by Henry on 7/25/25.
//

import SwiftUI
import Photos
import DesignSystem

struct AlbumGridItemView: View {
    let asset: PHAsset
    let isSelected: Bool
    let selectedIndex: Int?
    let viewModel: CustomAlbumViewModel
    let cellSize: CGFloat

    @State private var image: UIImage?
    
    init(asset: PHAsset, isSelected: Bool, selectedIndex: Int?, viewModel: CustomAlbumViewModel, cellSize: CGFloat) {
        self.asset = asset
        self.isSelected = isSelected
        self.selectedIndex = selectedIndex
        self.viewModel = viewModel
        self.cellSize = cellSize
        // State 변수를 ViewModel의 캐시 값으로 초기화합니다.
        _image = State(initialValue: viewModel.getCachedImage(for: asset))
    }

    var body: some View {
        ZStack {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                DesignSystem.Color.Gray_Button
            }
        }
        .frame(width: cellSize, height: cellSize)
        .clipped()
        .contentShape(Rectangle())
        .overlay(selectionOverlay)
        .onAppear {
            if image == nil {
                Task {
                    let thumbnailSize = CGSize(width: cellSize * UIScreen.main.scale, height: cellSize * UIScreen.main.scale)
                    self.image = await viewModel.fetchImage(for: asset, size: thumbnailSize)
                }
            }
        }

    }

    @ViewBuilder
    private var selectionOverlay: some View {
        if isSelected, let idx = selectedIndex {
            ZStack(alignment: .topTrailing) {
                Color.black.opacity(0.4)

                Text("\(idx + 1)")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(DesignSystem.Color.Prime)
                    .padding(4)
            }
        }
    }
}
