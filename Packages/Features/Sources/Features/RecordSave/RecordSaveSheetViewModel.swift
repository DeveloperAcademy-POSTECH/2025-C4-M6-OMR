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

@MainActor
public final class RecordSaveSheetViewModel: ObservableObject {
    @Published var recentImages: [UIImage] = []
    @Published var selectedImages: [UIImage] = []
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    
    let maxImageCount = 4
    
    func toggleImageSelection(_ image: UIImage) {
        if let index = selectedImages.firstIndex(of: image) {
            // 이미 선택된 사진이면 배열에서 제거
            selectedImages.remove(at: index)
        } else {
            // 새로 선택하는 사진이면, 최대 개수를 넘지 않았을 때만 배열에 추가
            if selectedImages.count < maxImageCount {
                selectedImages.append(image)
            }
        }
    }
    
    public var isSaveButtonDisabled: Bool {
        return selectedImages.isEmpty
    }
    
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
    
    func saveImages() {
        guard !selectedImages.isEmpty else { return }
        // TODO: 선택된 이미지를 저장하는 로직을 구현 예정

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
            selectedImages.append(contentsOf: newImages)
        }
    }
    
    // 최근 사진을 불러오는 로직
    private func fetchRecentPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 20
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        let imageManager = PHImageManager.default()
        let dispatchGroup = DispatchGroup()
        var fetchedImages: [UIImage] = []
        
        // 메인 스레드 블락을 방지하기 위해 비동기적으로 작업 수행
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        
        fetchResult.enumerateObjects { (asset, _, _) in
            dispatchGroup.enter()
            let targetSize = CGSize(width: 100, height: 100)
            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
                if let image = image {
                    fetchedImages.append(image)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.recentImages = fetchedImages
        }
    }
}
