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
    @ObservedObject var viewModel: CustomAlbumViewModel
    let cellSize: CGFloat
    
    @State private var image: UIImage?
    @State private var isImageLoaded = false // 이미지 로딩 완료 여부 추적
    
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
        .task(id: asset.localIdentifier) {
            // 이미 로딩된 이미지가 있으면 다시 로딩하지 않음
            guard !isImageLoaded else { return }
            
            let imageSize = CGSize(width: cellSize * UIScreen.main.scale, height: cellSize * UIScreen.main.scale)
            
            // 1단계: 캐시된 이미지 먼저 시도 (빠른 표시)
            if let cachedImage = await viewModel.fetchImage(
                for: asset,
                targetSize: imageSize,
                preferCached: true,
                highQuality: false
            ) {
                self.image = cachedImage
            }
            
            // 2단계: 고화질 이미지 로딩 (앨범에서도 고화질 사용)
            if let highQualityImage = await viewModel.fetchImage(
                for: asset,
                targetSize: imageSize,
                preferCached: false,
                highQuality: true
            ) {
                self.image = highQualityImage
                self.isImageLoaded = true // 고화질 로딩 완료 표시
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
                    .background(Circle().fill(DesignSystem.Color.Prime))
                    .padding(4)
            }
        }
    }
}
