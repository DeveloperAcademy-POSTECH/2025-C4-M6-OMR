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
        options.isNetworkAccessAllowed = false // 썸네일은 로컬만
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
        fetchInitialData()
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
    private func fetchInitialData() {
        isLoading = true
        checkPermission { [weak self] hasPermission in
            guard let self, hasPermission else {
                DispatchQueue.main.async { self?.isLoading = false }
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
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
                
                // --- 메인 스레드에서 UI 업데이트 ---
                DispatchQueue.main.async {
                    self.recentPhotoAssets = recentAssets
                    self.allPhotoAssetsResult = allAssetsResult
                    self.isLoading = false
                }
            }
        }
    }
    
    public func fetchImage(
        for asset: PHAsset,
        targetSize: CGSize,
        preferCached: Bool = true,
        highQuality: Bool = false
    ) async -> UIImage? {
        
        if preferCached {
            if let cachedImage = await requestCachedImageAsync(for: asset, targetSize: targetSize) {
                // 고화질이 필요하지 않으면 캐시된 이미지 반환
                if !highQuality {
                    return cachedImage
                }
                // 고화질이 필요한 경우에도 일단 캐시된 이미지를 먼저 반환할 수 있도록
            }
        }
        
        // 새로운 이미지 요청
        let options = highQuality ? highQualityOptions : thumbnailOptions
        
        return await withCheckedContinuation { continuation in
            var isResumed = false
            cachingImageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { image, info in
                guard !isResumed else { return }
                
                let isError = info?[PHImageErrorKey] != nil
                let isCancelled = (info?[PHImageCancelledKey] as? Bool) ?? false
                
                if let image {
                    continuation.resume(returning: image)
                    isResumed = true
                } else if isError || isCancelled {
                    continuation.resume(returning: nil)
                    isResumed = true
                }
            }
        }
    }
    
    /// 캐시에서 이미지를 비동기적으로 가져옴
    private func requestCachedImageAsync(for asset: PHAsset, targetSize: CGSize) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.isSynchronous = false // 비동기로 변경
            options.deliveryMode = .fastFormat
            options.isNetworkAccessAllowed = false // 캐시된 이미지만
            
            cachingImageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { image, info in
                // 캐시에서만 가져오므로 즉시 완료
                continuation.resume(returning: image)
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
        default: // .denied, .restricted
            completion(false)
        }
    }
}
