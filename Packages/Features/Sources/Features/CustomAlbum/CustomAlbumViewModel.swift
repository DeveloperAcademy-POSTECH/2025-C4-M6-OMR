//
//  CustomAlbumViewModel.swift
//  Features
//
//  Created by Henry on 7/28/25.
//

import Combine
import Foundation
import Photos
import SwiftUI

@MainActor
public final class CustomAlbumViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var recentPhotoAssets: [PHAsset] = []
    @Published var allPhotoAssetsResult: PHFetchResult<PHAsset>? // 전체 앨범을 위한 데이터 소스
    
    @Published var selectedAssets: [PHAsset] = []
    
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var isLoading = false
    
    // MARK: - Properties
    
    let maxImageCount = 4
    let selectionDidFinishPublisher = PassthroughSubject<[PHAsset], Never>()
    
    private let cachingImageManager = PHCachingImageManager()
    private var previousCachedIndices: IndexSet = IndexSet()
    
    private let thumbnailOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isNetworkAccessAllowed = false
        options.isSynchronous = false
        return options
    }()
    
    private let highQualityOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        return options
    }()
    
    // MARK: - Initialization
    
    public init() {
        // ✅ 초기화 완료 후 비동기 데이터 로딩 시작
        Task { @MainActor in
            await fetchInitialData()
        }
    }
    
    // MARK: - Caching Logic
    
    /// View가 나타날 때 호출되어, 첫 화면에 보일 이미지들의 캐싱을 시작합니다.
    /// - Parameter targetSize: 캐싱할 이미지의 크기 (View의 셀 크기와 일치해야 함)
    public func startInitialCaching(targetSize: CGSize) {
        guard let assets = allPhotoAssetsResult, assets.count > 0 else { return }
        
        // 이미 캐싱된 경우 중복 실행 방지
        guard previousCachedIndices.isEmpty else { return }
        
        let initialCacheCount = min(assets.count, 50)
        let initialIndices = IndexSet(0..<initialCacheCount)
        let assetsToCache = assets.objects(at: initialIndices)
        
        cachingImageManager.startCachingImages(
            for: assetsToCache,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: thumbnailOptions // 썸네일 옵션 사용
        )
        
        previousCachedIndices = initialIndices
    }
    
    /// 스크롤 시 View에서 호출되어, 화면에 보이거나 보일 예정인 셀들의 캐싱을 관리합니다.
    /// - Parameters:
    ///   - visibleIndices: 현재 화면에 보이는 셀들의 인덱스
    ///   - targetSize: 캐싱할 이미지의 크기 (View의 셀 크기와 일치해야 함)
    public func updateCachedAssets(visibleIndices: IndexSet, targetSize: CGSize) {
        guard let assets = allPhotoAssetsResult else { return }
        
        let buffer = 25
        let minIndex = max(0, (visibleIndices.min() ?? 0) - buffer)
        let maxIndex = min(assets.count - 1, (visibleIndices.max() ?? 0) + buffer)
        
        guard minIndex <= maxIndex else { return }
        
        let currentIndicesToCache = IndexSet(integersIn: minIndex...maxIndex)
        guard currentIndicesToCache != previousCachedIndices else { return }
        
        let newAssetsToCacheIndices = currentIndicesToCache.subtracting(previousCachedIndices)
        let oldAssetsToStopCachingIndices = previousCachedIndices.subtracting(currentIndicesToCache)
        
        if !newAssetsToCacheIndices.isEmpty {
            let assetsToCache = assets.objects(at: newAssetsToCacheIndices)
            cachingImageManager.startCachingImages(
                for: assetsToCache,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: thumbnailOptions // 썸네일 옵션 사용
            )
        }
        
        if !oldAssetsToStopCachingIndices.isEmpty {
            let assetsToStop = assets.objects(at: oldAssetsToStopCachingIndices)
            cachingImageManager.stopCachingImages(
                for: assetsToStop,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: thumbnailOptions
            )
        }
        
        previousCachedIndices = currentIndicesToCache
    }
    
    
    // MARK: - Data Fetching
    
    /// ViewModel 초기화 시 호출되어, 사진첩 데이터를 가져옵니다.
    @MainActor
    private func fetchInitialData() async {
        isLoading = true
        
        do {
            let hasPermission = await checkPermissionAsync()
            guard hasPermission else {
                isLoading = false
                return
            }
            
            // PhotoKit API는 메인 스레드에서 호출 보장됨 (@MainActor)
            await loadPhotoAssets()
            
        } catch {
            print("Photo permission error: \(error)")
            isLoading = false
        }
    }
    
    /// 사진 에셋들을 로딩합니다.
    @MainActor
    private func loadPhotoAssets() async {
        // --- 최근 사진 20개 가져오기 ---
        let recentFetchOptions = PHFetchOptions()
        recentFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        recentFetchOptions.fetchLimit = 20
        
        let recentResult = PHAsset.fetchAssets(with: .image, options: recentFetchOptions)
        var recentAssets: [PHAsset] = []
        recentResult.enumerateObjects { asset, _, _ in
            recentAssets.append(asset)
        }
        
        // --- 모든 사진에 대한 FetchResult 가져오기 ---
        let allFetchOptions = PHFetchOptions()
        allFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let allAssetsResult = PHAsset.fetchAssets(with: .image, options: allFetchOptions)
        
        // --- UI 업데이트 (메인 액터에서 자동 보장) ---
        self.recentPhotoAssets = recentAssets
        self.allPhotoAssetsResult = allAssetsResult
        self.isLoading = false
    }
    
    public func fetchImage(
        for asset: PHAsset,
        targetSize: CGSize,
        preferCached: Bool = true,
        highQuality: Bool = false
    ) async -> UIImage? {
        
        // 캐시 확인 (저화질 요청이고 캐시 우선인 경우)
        if preferCached && !highQuality {
            if let cachedImage = await requestCachedImageAsync(for: asset, targetSize: targetSize) {
                return cachedImage
            }
        }
        
        // 새로운 이미지 요청 (캐시에 없거나 고화질 필요한 경우)
        let options = highQuality ? highQualityOptions : thumbnailOptions
        
        return await withCheckedContinuation { continuation in
            cachingImageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { image, info in
                let isError = info?[PHImageErrorKey] != nil
                let isCancelled = (info?[PHImageCancelledKey] as? Bool) ?? false
                
                if let image {
                    continuation.resume(returning: image)
                } else if isError || isCancelled {
                    continuation.resume(returning: nil)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    /// 캐시에서 이미지를 비동기적으로 페칭 (실제 캐시된 이미지만 반환)
    private func requestCachedImageAsync(for asset: PHAsset, targetSize: CGSize) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .fastFormat
            options.isNetworkAccessAllowed = false
            options.resizeMode = .fast
            
            cachingImageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { image, info in
                // info 딕셔너리를 확인하여 실제 캐시된 이미지인지 검증
                let isFromCloud = (info?[PHImageResultIsInCloudKey] as? Bool) ?? false
                let isError = info?[PHImageErrorKey] != nil
                
                // 캐시된 이미지만 반환 (클라우드에서 가져오거나 에러가 있으면 nil)
                if let image = image, !isFromCloud, !isError {
                    continuation.resume(returning: image)
                } else {
                    // 캐시에 없거나 클라우드에서 가져와야 하는 경우 nil 반환
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    // MARK: - Asset Selection
    
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
    
    // MARK: - Permissions
    
    /// 사진 권한을 비동기적으로 확인하고 요청합니다.
    @MainActor
    private func checkPermissionAsync() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        self.authorizationStatus = status
        
        switch status {
        case .authorized, .limited:
            return true
            
        case .notDetermined:
            // async/await로 권한 요청
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            self.authorizationStatus = newStatus
            return newStatus == .authorized || newStatus == .limited
            
        default: // .denied, .restricted
            return false
        }
    }

}
