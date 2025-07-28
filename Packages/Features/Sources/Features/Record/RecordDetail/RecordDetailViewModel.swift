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

    // MARK: - Computed Properties
    public var isSaveButtonDisabled: Bool {
        guard let detail = detail, let originalDetail = originalDetail else {
            return true
        }
        
        if detail.images.isEmpty {
            return true
        }
        
        let isTitleChanged = detail.title != originalDetail.title
        let areImagesChanged = detail.images.count != originalDetail.images.count

        if !isTitleChanged && !areImagesChanged {
            return true
        }

        return false
    }
    
    // MARK: - Initialization
    
    public init() {
        // 기본 초기화 - 추후 필요시 기본 동작 추가
    }
    
//    public convenience init(record: Record) {
//        self.init() // 기존 init 호출
//        
//        // Task를 이용해 파일 경로로부터 이미지를 비동기적으로 불러옵니다.
//        Task {
//            var loadedImages: [UIImage] = []
//            for fileName in record.imageFileNames {
//                if let image = await FileStoreManager.shared.loadImage(fileName: fileName) {
//                    loadedImages.append(image)
//                }
//            }
//            
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy년 M월 d일"
//
//            // 불러온 이미지와 Record의 정보로 UI 모델을 생성합니다.
//            let detailModel = RecordDetailUIModel(
//                title: record.flower.name, // 제목은 우선 꽃 이름으로 설정
//                flowerName: record.flower.name,
//                flowerMeaning: record.flower.meaning,
//                location: "위치 정보 미정", // 위치 정보는 추후 추가
//                date: dateFormatter.string(from: Date()),
//                images: loadedImages
//            )
//
//            // @Published 프로퍼티를 업데이트하여 View에 반영합니다.
//            self.detail = detailModel
//            // 수정 기능을 위해 원본도 함께 저장해 둡니다.
//            self.originalDetail = detailModel
//        }
//    }
    
    public init(id: UUID) {
        fetchRecordDetails(id: id)
    }
    
    // ARCamera 연동을 위한 추가 초기화
    public convenience init(arRecord: ARRecordModel) {
        self.init()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월 d일"

        // 기존 fetchRecordDetails와 동일한 방식으로 Mock 이미지 생성
        let dummyPhotos = ["photo.artframe", "camera.fill", "tree.fill"]
        let images = dummyPhotos.compactMap { UIImage(systemName: $0) }

        // ARRecordModel의 데이터를 RecordDetailUIModel로 변환
        let mockDetail = RecordDetailUIModel(
            title: arRecord.title.isEmpty ? "제목 없음" : arRecord.title,
            flowerName: "프리지아",  // TODO: MarkerType에서 꽃 이름 가져오기
            flowerMeaning: "영원한 사랑",  // TODO: MarkerType에서 꽃말 가져오기
            location: "포항공과대학교",  // TODO: 실제 주소 정보 사용
            date: dateFormatter.string(from: arRecord.createdDate),
            images: images
        )

        self.setDetail(mockDetail)
    }
  
    // MARK: - Methods
    
    // ARCamera에서 사용할 수 있도록 detail을 설정하는 메서드
    func setDetail(_ detail: RecordDetailUIModel) {
        self.detail = detail
        self.originalDetail = detail
    }
    
    /// id 기반으로 RecordDetailUIModel 생성 및 detail 세팅
    func fetchRecordDetails(id: UUID) {
        let motes = MockDataProvider.mockObjects()
        
        guard let mote = motes.first(where: { $0.id == id }) else {
            print("❌ 해당 ID의 Mote를 찾을 수 없습니다.")
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월 d일"

        let images: [UIImage] = mote.images.compactMap {
            UIImage(named: $0) ?? UIImage(systemName: "photo")
        }

        self.detail = RecordDetailUIModel(
            title: mote.title,
            flowerName: mote.flower.name,
            flowerMeaning: mote.flower.floriography,
            location: mote.address,
            date: dateFormatter.string(from: mote.createdAt),
            images: images
        )
        
        self.originalDetail = self.detail
    }

    // MARK: - User Actions

    func editButtonTapped() {
        originalDetail = detail
        isEditing = true
    }

    func saveButtonTapped() {
        if detail?.title.isEmpty == true {
            detail?.title = originalDetail?.title ?? ""
        }

        // TODO: 변경된 detail 객체를 UseCase에 전달하여 저장하는 로직
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
                if let image = await albumViewModel.fetchImage(for: asset, size: PHImageManagerMaximumSize) {
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

extension RecordDetailViewModel {
    public convenience init(summary: ObjectSummary) {
        self.init()
        // TODO: summary 객체로부터 실제 데이터를 받아와 프로퍼티를 채우는 로직 구현
    }
}
