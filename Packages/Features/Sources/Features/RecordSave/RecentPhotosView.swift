//
//  RecentPhotosView.swift
//  Features
//
//  Created by Henry on 7/25/25.
//

import SwiftUI
import PhotosUI
import DesignSystem
import Photos

struct RecentPhotosView: View {
    @ObservedObject var viewModel: RecordSaveSheetViewModel
    
    var body: some View {
        VStack {
            switch viewModel.albumViewModel.authorizationStatus {
            case .authorized, .limited:
                authorizedView
            case .denied, .restricted:
                deniedView
            default:
                loadingView
            }
        }
    }
    
    // MARK: - Composed Subviews
    
    @ViewBuilder
    private var authorizedView: some View {
        if viewModel.albumViewModel.isLoading {
            loadingView
        } else if viewModel.recentPhotoAssets.isEmpty {
            VStack {
                Text("사진이 없습니다.")
                    .font(.headline)
                Text("카메라로 사진을 촬영하여 추억을 기록해보세요.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }.frame(height: 100)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(viewModel.recentPhotoAssets, id: \.self) { asset in
                        PhotoItemView(
                            asset: asset,
                            isSelected: viewModel.albumViewModel.selectedAssets.contains(asset),
                            selectedIndex: viewModel.albumViewModel.selectedAssets.firstIndex(of: asset),
                            viewModel: viewModel.albumViewModel
                        ) {
                            viewModel.handleRecentPhotoTap(for: asset)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 100)
        }
    }
    
    @ViewBuilder
    private var deniedView: some View {
        VStack(spacing: 8) {
            Text("사진첩 접근 권한이 필요합니다.")
                .font(.headline)
            Text("설정에서 사진 접근 권한을 허용해주세요.")
                .font(.subheadline)
            Button("설정으로 이동") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .padding(.top, 8)
        }
        .frame(height: 100)
    }
    
    @ViewBuilder
    private var loadingView: some View {
        ProgressView().frame(height: 100)
    }
}

// MARK: - Subviews

private struct PhotoItemView: View {
    let asset: PHAsset
    let isSelected: Bool
    let selectedIndex: Int?
    let viewModel: CustomAlbumViewModel
    let action: () -> Void
    
    @State private var image: UIImage?
    @State private var isImageLoaded = false // 이미지 로딩 완료 여부 추적
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(Color(red: 0.85, green: 0.85, blue: 0.85))
                }
            }
            .frame(width: 100, height: 100)
            .clipped()
            .overlay {
                if isSelected, let index = selectedIndex {
                    SelectionOverlay(index: index)
                }
            }
        }
        .buttonStyle(.plain)
        .task(id: asset.localIdentifier) {
            // 이미 로딩된 이미지가 있으면 다시 로딩하지 않음
            guard !isImageLoaded else { return }
            
            let imageSize = CGSize(width: 250, height: 250) // RecentPhotosView 아이템 크기에 맞는 사이즈
            
            // 1단계: 캐시된 이미지 먼저 시도 (빠른 표시)
            if let cachedImage = await viewModel.fetchImage(
                for: asset,
                targetSize: imageSize,
                preferCached: true,
                highQuality: false
            ) {
                self.image = cachedImage
            }
            
            // 2단계: 고화질 이미지 로딩 (최근 사진도 고화질로 표시)
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
}

private struct SelectionOverlay: View {
    let index: Int
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.opacity(0.4)
            
            Text("\(index + 1)")
                .font(.caption.bold())
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(DesignSystem.Color.Prime))
                .padding(4)
        }
    }
}
