//
//  File.swift
//  Features
//
//  Created by Henry on 7/28/25.
//

import Combine
import Photos
import SwiftUI

@MainActor
public final class CustomAlbumViewModel: ObservableObject {
    
    @Published var recentPhotoAssets: [PHAsset] = []
    @Published var allPhotoAssetsResult: PHFetchResult<PHAsset>?
    
    @Published var selectedAssets: [PHAsset] = []
    
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var isLoading = false
    
    private let cachingImageManager = PHCachingImageManager()
    private var imageCache: [String: UIImage] = [:]
    
    let maxImageCount = 4
    
    let selectionDidFinishPublisher = PassthroughSubject<[PHAsset], Never>()
    
    public init() {
        fetchInitialRecentAssets()
    }
    
    public func getCachedImage(for asset: PHAsset) -> UIImage? {
         return imageCache[asset.localIdentifier]
     }
    
    func fetchInitialRecentAssets() {
        isLoading = true
        checkPermission { [weak self] hasPermission in
            guard let self = self, hasPermission else {
                DispatchQueue.main.async { self?.isLoading = false }
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [
                    NSSortDescriptor(key: "creationDate", ascending: false)
                ]
                fetchOptions.fetchLimit = 20

                let fetchResult = PHAsset.fetchAssets(
                    with: .image,
                    options: fetchOptions
                )
                var assets: [PHAsset] = []
                fetchResult.enumerateObjects { asset, _, _ in
                    assets.append(asset)
                }

                DispatchQueue.main.async {
                    self.recentPhotoAssets = assets
                    self.isLoading = false
                }
            }
        }
    }
    
    // 커스텀 앨범에서 사진 선택/해제
    func toggleAssetSelection(_ asset: PHAsset) {
        if let index = selectedAssets.firstIndex(of: asset) {
            selectedAssets.remove(at: index)
        } else if selectedAssets.count < maxImageCount {
            selectedAssets.append(asset)
        }
    }
    
    func finalizeSelection() {
         selectionDidFinishPublisher.send(selectedAssets)
     }
    
    func clearSelectedAssets() {
        selectedAssets.removeAll()
    }
    
    func prepareForAllPhotos() {
        guard allPhotoAssetsResult == nil else { return }

        checkPermission { [weak self] hasPermission in
            guard let self = self, hasPermission else { return }

            let opts = PHFetchOptions()
            opts.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false)
            ]
            self.allPhotoAssetsResult = PHAsset.fetchAssets(
                with: .image,
                options: opts
            )
        }
    }
    
    public func fetchImage(for asset: PHAsset, size: CGSize) async -> UIImage? {
            // 캐시에 이미지가 있으면 즉시 반환합니다.
            if let cachedImage = imageCache[asset.localIdentifier] {
                return cachedImage
            }
            
            // 캐시에 없으면 PHCachingImageManager를 통해 이미지를 요청합니다.
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true

            let image = await withCheckedContinuation { continuation in
                cachingImageManager.requestImage(
                    for: asset,
                    targetSize: size,
                    contentMode: .aspectFill,
                    options: options
                ) { image, _ in
                    continuation.resume(returning: image)
                }
            }
            
            // 로드된 이미지를 캐시에 저장합니다.
            if let loadedImage = image {
                imageCache[asset.localIdentifier] = loadedImage
            }
            
            return image
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
                    completion(
                        newStatus == .authorized || newStatus == .limited
                    )
                }
            }
        default:  // .denied, .restricted
            completion(false)
        }
    }
    
    
}



