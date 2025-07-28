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
            switch viewModel.authorizationStatus {
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
        if viewModel.isLoading {
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
                            isSelected: viewModel.selectedAssets.contains(asset),
                            selectedIndex: viewModel.selectedAssets.firstIndex(of: asset),
                            viewModel: viewModel
                        ) {
                            viewModel.toggleAssetSelection(asset)
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
    let viewModel: RecordSaveSheetViewModel
    let action: () -> Void
    
    @State private var image: UIImage?

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
        .onAppear {
            Task {
                self.image = await viewModel.fetchImage(for: asset, size: CGSize(width: 250, height: 250))
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
