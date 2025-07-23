//
//  RecordSaveSheetView.swift
//  Features
//
//  Created by eunsong on 7/15/25.
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
    
    @Published var detail: SelectedFlowerModel?
    @Published var recentImages: [UIImage] = []
    @Published var selectedImages: [UIImage] = []
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    
    public var isSaveButtonDisabled: Bool {
        return selectedImages.isEmpty
    }
    
    let maxImageCount = 4
    
    // MARK: - Initialization
    
    public init() {
        fetchFlower()
        checkPermissionAndFetchPhotos()
    }
    
    // MARK: - User Actions
    
    func toggleImageSelection(_ image: UIImage) {
        if let index = selectedImages.firstIndex(of: image) {
            selectedImages.remove(at: index)
        } else {
            if selectedImages.count < maxImageCount {
                selectedImages.append(image)
            }
        }
    }
    
    func saveImages() {
        guard !selectedImages.isEmpty else { return }
        // TODO: 선택된 사진을 저장하는 UseCase를 구현
    }
    
    func addImages(from items: [PhotosPickerItem]) {
        Task {
            var newImages: [UIImage] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    newImages.append(uiImage)
                }
            }
            withAnimation(.spring()) {
                selectedImages.append(contentsOf: newImages)
            }
        }
    }
    
    // MARK: - Data Fetching
    
    func checkPermissionAndFetchPhotos() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        self.authorizationStatus = status
        
        switch status {
        case .authorized, .limited:
            fetchRecentPhotos()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    self.authorizationStatus = newStatus
                    if newStatus == .authorized {
                        self.fetchRecentPhotos()
                    }
                }
            }
        default:
            break
        }
    }
    
    private func fetchFlower() {
        // 임시 데이터 생성
        self.detail = SelectedFlowerModel(
            name: "프리지아",
            meaning: "영원한 사랑",
            imageName: "flower"
        )
    }
    
    private func fetchRecentPhotos() {
        Task {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.fetchLimit = 20
            
            let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            let images = await withTaskGroup(of: UIImage?.self, returning: [UIImage].self) { group in
                var collectedImages: [UIImage] = []
                
                for index in 0..<fetchResult.count {
                    let asset = fetchResult.object(at: index)
                    group.addTask {
                        return await self.fetchImage(for: asset, size: CGSize(width: 100, height: 100))
                    }
                }
                
                for await image in group {
                    if let image = image {
                        collectedImages.append(image)
                    }
                }
                
                return collectedImages
            }
            
            self.recentImages = images
        }
    }
    
    private func fetchImage(for asset: PHAsset, size: CGSize) async -> UIImage? {
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        
        return await withCheckedContinuation { continuation in
            imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}
