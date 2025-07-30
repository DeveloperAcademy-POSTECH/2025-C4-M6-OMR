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
    @Published var selectedImages: [UIImage] = []
    @Published var didSelectFromLibrary: Bool = false
    
    @Published var isLoading = false
    
    let albumViewModel: CustomAlbumViewModel
    
    private var cancellables = Set<AnyCancellable>()
    let onSave: (FinalRecordPayload) -> Void
    
    public var isSaveButtonDisabled: Bool {
        return selectedImages.isEmpty
    }
    
    // MARK: - Initialization
    public init(
        info: RecordSaveSheetInfo,
        albumViewModel: CustomAlbumViewModel,
        onSave: @escaping (FinalRecordPayload) -> Void
    ) {
        self.flowerName = info.flower.name
        self.flowerMeaning = info.flower.floriography
        self.flowerImageName = info.flower.thumbnailLarge
        self.address = info.address
        self.albumViewModel = albumViewModel
        self.onSave = onSave
        bindAlbumViewModel()
    }
    
    // MARK: - Binding
    
    private func bindAlbumViewModel() {
        // 자식 ViewModel의 변화를 감지하여 View를 갱신
        albumViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        // 최근 사진 목록 동기화
        albumViewModel.$recentPhotoAssets
            .receive(on: DispatchQueue.main)
            .assign(to: \.recentPhotoAssets, on: self)
            .store(in: &cancellables)
        
        // 전체 앨범에서 '완료'를 눌렀을 때의 이벤트 구독
        albumViewModel.selectionDidFinishPublisher
            .sink { [weak self] selectedAssets in
                // View 전환이 필요한 경우
                self?.processSelectedAssets(selectedAssets, shouldFinalizeSelection: true)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - User Actions
    
    /// RecentPhotosView에서 사진을 탭했을 때 호출될 메서드
    public func handleRecentPhotoTap(for asset: PHAsset) {
        albumViewModel.toggleAssetSelection(asset)
        // View 전환이 필요 없는 경우
        processSelectedAssets(albumViewModel.selectedAssets, shouldFinalizeSelection: false)
    }
    
    public func save() {
        isLoading = true
        Task {
            let images = self.selectedImages
            var savedFileNames: [String] = []
            
            for image in images {
                if let fileName = await FileStoreManager.shared.saveImage(image) {
                    savedFileNames.append(fileName)
                }
            }
            
            let payload = FinalRecordPayload(
                imageFileNames: savedFileNames,
                description: ""
            )
            
            onSave(payload)
            isLoading = false
        }
    }
    
    private func processSelectedAssets(_ assets: [PHAsset], shouldFinalizeSelection: Bool) {
        Task {
            self.isLoading = true
            var images: [UIImage] = []
            
            for asset in assets {
                // 새로 통합된 fetchImage 메서드 사용 - 최종 선택이므로 고화질로 요청
                if let image = await albumViewModel.fetchImage(
                    for: asset,
                    targetSize: CGSize(width: 400, height: 400),
                    preferCached: false, // 최종 저장용이므로 캐시 무시하고 새로 요청
                    highQuality: true    // 고화질로 요청
                ) {
                    images.append(image)
                }
            }
            self.selectedImages = images
            
            if shouldFinalizeSelection {
                self.didSelectFromLibrary = !images.isEmpty
            }
            
            self.isLoading = false
        }
    }
    
    public func removeSelectedImage(_ image: UIImage) {
        if let index = selectedImages.firstIndex(of: image) {
            selectedImages.remove(at: index)
            albumViewModel.selectedAssets.remove(at: index)
            if selectedImages.isEmpty {
                didSelectFromLibrary = false
            }
        }
    }
    
    // MARK: - Pass-through Methods to AlbumViewModel
    
    
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
