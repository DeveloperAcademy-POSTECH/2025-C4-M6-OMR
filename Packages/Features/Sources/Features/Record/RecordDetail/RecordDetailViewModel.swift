import Combine
import Domain
import PhotosUI
import SwiftUI

struct RecordDetailUIModel {
    var title: String
    var flowerName: String
    var flowerMeaning: String
    var location: String
    var date: String
    var images: [UIImage]
}

@MainActor
public final class RecordDetailViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var detail: RecordDetailUIModel?
    @Published var isEditing: Bool = false
    @Published var isLoading: Bool = false
    
    // 수정 전 원본 데이터를 저장할 프로퍼티
    private var originalDetail: RecordDetailUIModel?
    // Combine 구독 관리를 위한 cancellables
    private var cancellables: Set<AnyCancellable> = []
    private let fetchRecordDetailUseCase: FetchRecordDetailUseCase
    
    // MARK: - Computed Properties
    public var isSaveButtonDisabled: Bool {
        // 수정 모드가 아닐 때는 항상 비활성화
        guard isEditing else { return true }
        
        // detail이 존재하고 이미지가 하나 이상 있어야 저장 버튼 활성화
        guard let detail = detail else { return true }
        
        return detail.images.isEmpty
    }
    
    
    // MARK: - Initialization
    
    public init(id: UUID, fetchRecordDetailUseCase: FetchRecordDetailUseCase) {
        self.fetchRecordDetailUseCase = fetchRecordDetailUseCase
        
        // 생성과 동시에 데이터 로딩 시작
        Task {
            await fetchFullRecordDetail(id: id)
        }
    }
    
    private func fetchFullRecordDetail(id: UUID) async {
        self.isLoading = true
        
        do {
            // 1. UseCase를 통해 기록의 기본 정보를 가져옵니다.
            let domainDetail = try await fetchRecordDetailUseCase(id: id)
            
            // 2. 파일 이름 목록으로 실제 이미지를 비동기 로드합니다.
            let images = await loadImages(from: domainDetail.record.photos)
            
            // 3. 모든 데이터를 사용해 최종 UI 모델을 만듭니다.
            let uiModel = mapToUIModel(entity: domainDetail, images: images)
            
            // 4. Main 쓰레드에서 UI 상태를 업데이트합니다.
            self.detail = uiModel
            self.originalDetail = uiModel
            
        } catch {
            print("RecordDetailViewModel fetch error: \(error.localizedDescription)")
            // TODO: 사용자에게 에러 알림 표시
        }
        
        self.isLoading = false
    }
    
    private func loadImages(from photos: [Photo]) async -> [UIImage] {
        guard !photos.isEmpty else { return [] }
        
        return await withTaskGroup(of: UIImage?.self, body: { group in
            var loadedImages: [UIImage] = []
            
            for photo in photos {
                group.addTask {
                    // FileStoreManager를 거치지 않고 URL에서 직접 로드 시도
                    do {
                        let (data, _) = try await URLSession.shared.data(from: photo.url)
                        return UIImage(data: data)
                    } catch {
                        return nil
                    }
                }
            }
            
            for await image in group {
                if let image = image {
                    loadedImages.append(image)
                }
            }
            return loadedImages
        })
    }
    
    // MARK: - Methods
    
    // ARCamera에서 사용할 수 있도록 detail을 설정하는 메서드
    func setDetail(_ detail: RecordDetailUIModel) {
        self.detail = detail
        self.originalDetail = detail
    }
    
    private func mapToUIModel(entity: RecordDetail, images: [UIImage]) -> RecordDetailUIModel {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월 d일"
        
        let locationString = entity.record.address.fullAddress
        
        let titleString: String
        // entity.record.title이 nil이 아니면서, 공백을 제외한 실제 내용이 있을 경우
        if let originalTitle = entity.record.title, !originalTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            titleString = originalTitle
        } else {
            // 그 외의 경우 (nil이거나 빈 문자열일 때) location을 사용
            titleString = "\(locationString)에서"
        }
        
        return RecordDetailUIModel(
            title: titleString,
            flowerName: entity.marker.displayName,
            flowerMeaning: entity.marker.floriography,
            location: locationString,
            date: dateFormatter.string(from: entity.record.date),
            images: images
        )
    }
    
    /// id 기반으로 RecordDetailUIModel 생성 및 detail 세팅
    //    func fetchRecordDetails(id: UUID) {
    //        let motes = MockDataProvider.mockObjects()
    //
    //        guard let mote = motes.first(where: { $0.id == id }) else {
    //            print("❌ 해당 ID의 Mote를 찾을 수 없습니다.")
    //            return
    //        }
    //
    //        let dateFormatter = DateFormatter()
    //        dateFormatter.dateFormat = "yyyy년 M월 d일"
    //
    //        let images: [UIImage] = mote.images.compactMap {
    //            UIImage(named: $0) ?? UIImage(systemName: "photo")
    //        }
    //
    //        self.detail = RecordDetailUIModel(
    //            title: mote.title,
    //            flowerName: mote.flower.name,
    //            flowerMeaning: mote.flower.floriography,
    //            location: mote.address,
    //            date: dateFormatter.string(from: mote.createdAt),
    //            images: images
    //        )
    //
    //        self.originalDetail = self.detail
    //    }
    
    // MARK: - User Actions
    
    func editButtonTapped() {
        originalDetail = detail
        isEditing = true
    }
    
    func saveButtonTapped() {
        if let detail = detail,
           detail.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.detail?.title = "\(detail.location)에서"
        }
        
        // TODO: 변경된 detail 객체를 저장
        print("저장할 제목: \(detail?.title ?? "")")
        isEditing = false
    }
    
    
    func deleteButtonTapped() {
        print("삭제 버튼 탭됨")
    }
    
    public func subscribeToAlbumEvents(albumViewModel: CustomAlbumViewModel) {
        albumViewModel.selectionDidFinishPublisher
            .sink { [weak self] selectedAssets in
                // 앨범에서 선택이 완료되면, 이미지 추가 로직을 실행합니다.
                self?.addImages(from: selectedAssets, using: albumViewModel)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Image Handling
    
    func addImages(from assets: [PHAsset], using albumViewModel: CustomAlbumViewModel) {
        guard detail != nil else { return }
        
        isLoading = true
        Task {
            var newImages: [UIImage] = []
            
            for asset in assets {
                // 레코드 상세에 추가하는 이미지이므로 최고 품질로 요청
                if let image = await albumViewModel.fetchImage(
                    for: asset,
                    targetSize: PHImageManagerMaximumSize, // 원본에 가까운 최고 해상도 요청
                    preferCached: false, // 최고 품질이므로 캐시 무시하고 새로 요청
                    highQuality: true    // 최고 품질로 요청
                ) {
                    newImages.append(image)
                }
            }
            detail?.images.append(contentsOf: newImages)
            isLoading = false
        }
    }
    
    func deleteImage(_ image: UIImage) {
        detail?.images.removeAll { $0 == image }
    }
}

