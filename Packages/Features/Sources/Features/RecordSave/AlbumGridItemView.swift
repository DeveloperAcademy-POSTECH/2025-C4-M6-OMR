//
//  AlbumGridItemView.swift
//  Features
//
//  Created by Henry on 7/25/25.
//

import SwiftUI
import Photos

struct AlbumGridItemView: View {
    let asset: PHAsset
    let isSelected: Bool
    let selectedIndex: Int?
    let viewModel: RecordSaveSheetViewModel
    let cellSize: CGFloat

    @State private var image: UIImage?

    var body: some View {
        ZStack {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray.opacity(0.3)
            }
        }
        .frame(width: cellSize, height: cellSize)
        .clipped()
        .contentShape(Rectangle())
        .overlay(selectionOverlay)
        .onAppear {
            Task {
                // thumbnailSize를 cellSize에 맞춰 요청하여 화질 최적화
                let thumbnailSize = CGSize(width: cellSize * UIScreen.main.scale, height: cellSize * UIScreen.main.scale)
                self.image = await viewModel.fetchImage(for: asset, size: thumbnailSize)
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
                    .background(Circle().fill(Color(red: 0.43, green: 0.65, blue: 0.96)))
                    .padding(4)
            }
        }
    }
}
