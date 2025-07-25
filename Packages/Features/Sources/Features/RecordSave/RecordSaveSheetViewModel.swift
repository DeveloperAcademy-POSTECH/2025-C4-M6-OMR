//
//  RecordSaveSheetViewModel.swift
//  Features
//
//  Created by eunsong on 7/25/25.
//

import SwiftUI
import Combine
import Domain
import PhotosUI
import Photos

struct SelectedFlowerModel {
    let id = UUID()
    let name: String
    let meaning: String
    let imageName: String
}

@MainActor
public final class RecordSaveSheetViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var detail: SelectedFlowerModel?
    
    // RecentPhotosView를 위한 20개의 에셋 배열
    @Published var recentPhotoAssets: [PHAsset] = []
    // CustomAlbumView를 위한 전체 사진 목록
    @Published var allPhotoAssetsResult: PHFetchResult<PHAsset>?
    
    @Published var selectedAssets: [PHAsset] = []
    @Published var selectedImages: [UIImage] = []
    
    @Published var didSelectFromLibrary: Bool = false
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var isLoading = false
    
    private let cachingImageManager = PHCachingImageManager()
    
    public var isSaveButtonDisabled: Bool {
        return selectedAssets.isEmpty
    }
    
    let maxImageCount = 4
    
    // MARK: - Initialization
    
    public init() {
        fetchFlower()
        fetchInitialRecentAssets() // 앱 시작 시 최근 에셋 20개 우선 호출
    }
    
    // MARK: - User Actions
    
    func finalizeAssetSelection() {
        Task {
            self.isLoading = true
            var images: [UIImage] = []
            for asset in selectedAssets {
                if let image = await fetchImage(for: asset, size: CGSize(width: 400, height: 400)) {
                    images.append(image)
                }
            }
            self.selectedImages = images
            self.didSelectFromLibrary = true
            self.isLoading = false
        }
    }
    
    func removeSelectedImage(_ image: UIImage) {
        if let index = selectedImages.firstIndex(of: image) {
            selectedImages.remove(at: index)
            if selectedAssets.indices.contains(index) {
                selectedAssets.remove(at: index)
            }
        }
    }
    
    func toggleAssetSelection(_ asset: PHAsset) {
        if let index = selectedAssets.firstIndex(of: asset) {
            selectedAssets.remove(at: index)
        } else if selectedAssets.count < maxImageCount {
            selectedAssets.append(asset)
        }
    }
    
    func saveImages() {
        guard !selectedAssets.isEmpty else { return }
        Task {
            var imagesToSave: [UIImage] = []
            for asset in selectedAssets {
                if let image = await fetchImage(for: asset, size: PHImageManagerMaximumSize) {
                    imagesToSave.append(image)
                }
            }
            // TODO: imagesToSave 배열을 사용하여 실제 저장 UseCase에 전달
            print("\(imagesToSave.count)개의 이미지가 저장 준비 완료")
        }
    }
    
    func clearSelectedAssets() {
        selectedAssets.removeAll()
        didSelectFromLibrary = false
    }
    
    // MARK: - Data Fetching
    
    private func fetchFlower() {
        self.detail = SelectedFlowerModel(name: "프리지아", meaning: "영원한 사랑", imageName: "flower")
    }
    
    /// RecentPhotosView를  위한 최근 사진 20개 우선 호출
    func fetchInitialRecentAssets() {
        isLoading = true
        checkPermission { [weak self] hasPermission in
            guard let self = self, hasPermission else {
                DispatchQueue.main.async { self?.isLoading = false }
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.fetchLimit = 20
                
                let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                var assets: [PHAsset] = []
                fetchResult.enumerateObjects { asset, _, _ in assets.append(asset) }
                
                DispatchQueue.main.async {
                    self.recentPhotoAssets = assets
                    self.isLoading = false
                }
            }
        }
    }
    
    /// CustomAlbumView를 위해 전체 사진 목록(PHFetchResult) 준비
    func prepareForAllPhotos() {
        guard allPhotoAssetsResult == nil else { return } // 이미 로드했다면 다시 로드하지 않음

        checkPermission { [weak self] hasPermission in
            guard let self = self, hasPermission else { return }

            let opts = PHFetchOptions()
            opts.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            self.allPhotoAssetsResult = PHAsset.fetchAssets(with: .image, options: opts)
        }
    }
    
    private func checkPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        self.authorizationStatus = status
        
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    self.authorizationStatus = newStatus
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        default:
            completion(false)
        }
    }

    /// 주어진 PHAsset으로 UIImage를 비동기적으로 호출  (캐싱 적용).
    public func fetchImage(for asset: PHAsset, size: CGSize) async -> UIImage? {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        return await withCheckedContinuation { continuation in
            cachingImageManager.requestImage(for: asset,
                                         targetSize: size,
                                         contentMode: .aspectFill,
                                         options: options) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}
