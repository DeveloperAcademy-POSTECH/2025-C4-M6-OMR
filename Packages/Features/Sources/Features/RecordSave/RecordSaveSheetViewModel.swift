import Combine
import Domain
import Photos
import PhotosUI
import SwiftUI

@MainActor
public final class RecordSaveSheetViewModel: ObservableObject {

    // MARK: - Properties
    @Published var flowerName: String
    @Published var flowerMeaning: String
    @Published var flowerImageName: String
    @Published var address: String

    @Published var recentPhotoAssets: [PHAsset] = []
    @Published var allPhotoAssetsResult: PHFetchResult<PHAsset>?

    @Published var selectedAssets: [PHAsset] = []
    @Published var selectedImages: [UIImage] = []

    @Published var didSelectFromLibrary: Bool = false
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var isLoading = false

    private let cachingImageManager = PHCachingImageManager()
    private let onSave: (FinalRecordData) -> Void

    public var isSaveButtonDisabled: Bool {
        return selectedAssets.isEmpty
    }

    let maxImageCount = 4

    // MARK: - Initialization
    public init(
        info: RecordSaveSheetInfo,
        onSave: @escaping (FinalRecordData) -> Void
    ) {
        self.flowerName = info.flower.name
        self.flowerMeaning = info.flower.floriography
        self.flowerImageName = info.flower.thumbnail
        self.address = info.address
        self.onSave = onSave

        fetchInitialRecentAssets()
    }

    // MARK: - User Actions

    func save() {
        isLoading = true
        Task {
            let finalImages = await fetchSelectedImages()
            let finalData = FinalRecordData(
                images: finalImages,
                description: ""
            )
            onSave(finalData)
            isLoading = false
        }
    }

    private func fetchSelectedImages() async -> [UIImage] {
        var images: [UIImage] = []
        for asset in selectedAssets {
            if let image = await fetchImage(
                for: asset,
                size: PHImageManagerMaximumSize
            ) {
                images.append(image)
            }
        }
        return images
    }

    /// 커스텀 앨범에서 '완료'를 눌렀을 때 호출
    func finalizeAssetSelection() {
        Task {
            self.isLoading = true
            var images: [UIImage] = []
            for asset in selectedAssets {
                if let image = await fetchImage(
                    for: asset,
                    size: CGSize(width: 400, height: 400)
                ) {
                    images.append(image)
                }
            }
            self.selectedImages = images
            self.didSelectFromLibrary = true
            self.isLoading = false
        }
    }

    /// 최종 선택된 사진 그리드에서 이미�� 삭제
    func removeSelectedImage(_ image: UIImage) {
        if let index = selectedImages.firstIndex(of: image) {
            selectedImages.remove(at: index)
            if selectedAssets.indices.contains(index) {
                selectedAssets.remove(at: index)
            }
        }
    }

    /// 커스텀 앨범에서 사진 선택/해제
    func toggleAssetSelection(_ asset: PHAsset) {
        if let index = selectedAssets.firstIndex(of: asset) {
            selectedAssets.remove(at: index)
        } else if selectedAssets.count < maxImageCount {
            selectedAssets.append(asset)
        }
    }

    /// 선택된 모든 에셋 초기화
    func clearSelectedAssets() {
        selectedAssets.removeAll()
        didSelectFromLibrary = false
    }

    // MARK: - Data Fetching

    /// RecentPhotosView를 위해 최근 에셋 20개만 불러옵니다.
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

    func prepareForAllPhotos() {
        guard allPhotoAssetsResult == nil else { return }  // 이미 로드했으면 다시 재로드 X

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

    /// 권한을 확인하고 요청하는 공통 헬퍼 메서드
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

    /// 주어진 PHAsset으로 UIImage를 비동기적으로 불러옵니다 (캐싱 적용).
    public func fetchImage(for asset: PHAsset, size: CGSize) async -> UIImage? {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        return await withCheckedContinuation { continuation in
            cachingImageManager.requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}

public struct SelectedFlowerModel {
    public let id: UUID
    public let name: String
    public let meaning: String
    public let imageName: String

    public init(
        id: UUID = UUID(),
        name: String,
        meaning: String,
        imageName: String
    ) {
        self.id = id
        self.name = name
        self.meaning = meaning
        self.imageName = imageName
    }
}

public struct Record {
    public let id: UUID
    public let flower: SelectedFlowerModel
    public let imageFileNames: [String]

    public init(
        id: UUID = UUID(),
        flower: SelectedFlowerModel,
        imageFileNames: [String]
    ) {
        self.id = id
        self.flower = flower
        self.imageFileNames = imageFileNames
    }
}
