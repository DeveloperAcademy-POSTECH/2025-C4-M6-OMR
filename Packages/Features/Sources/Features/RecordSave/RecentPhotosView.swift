//
//  RecentPhotosView.swift
//  Features
//
//  Created by Henry on 7/22/25.
//

import SwiftUI
import PhotosUI
import DesignSystem

struct RecentPhotosView: View {
    @ObservedObject var viewModel: RecordSaveSheetViewModel
    
    var body: some View {
        VStack {
            // 현재 권한 상태에 따른 분기
            switch viewModel.authorizationStatus {
            case .authorized, .limited:
                authorizedView
            case .denied, .restricted:
                deniedView
            default:
                loadingView
            }
        }
        .onAppear {
            viewModel.checkPermissionAndFetchPhotos()
        }
    }
    
    // MARK: - Composed Subviews
    
    // 권한이 허용되었을 때의 뷰
    @ViewBuilder
    private var authorizedView: some View {
        if viewModel.recentImages.isEmpty {
            loadingView
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(viewModel.recentImages, id: \.self) { image in
                        PhotoItemView(
                            image: image,
                            isSelected: viewModel.selectedImages.contains(image),
                            selectedIndex: viewModel.selectedImages.firstIndex(of: image)
                        ) {
                            viewModel.toggleImageSelection(image)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(height: 100)
        }
    }
    
    // 권한이 거부되었을 때의 뷰
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
        .frame(height: 72)
    }
    
    // 로딩 중이거나 상태를 알 수 없을 때의 뷰
    @ViewBuilder
    private var loadingView: some View {
        ProgressView().frame(height: 72)
    }
}

// MARK: - Subviews

private struct PhotoItemView: View {
    let image: UIImage
    let isSelected: Bool
    let selectedIndex: Int?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipped()
                .overlay {
                    if isSelected, let index = selectedIndex {
                        SelectionOverlay(index: index)
                    }
                }
        }
        .buttonStyle(.plain)
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
                .background(Circle().fill(Color(red: 0.43, green: 0.65, blue: 0.96)))
                .padding(4)
        }
    }
}

