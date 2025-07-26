//
//  RecordDetailViewModel.swift
//  Features
//
//  Created by Henry on 7/19/25.
//

import SwiftUI
import Combine
import Domain
import PhotosUI

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
    
    // 수정 전 원본 데이터를 저장할 프로퍼티
    private var originalDetail: RecordDetailUIModel?
    
    // MARK: - Computed Properties
    public var isSaveButtonDisabled: Bool {
        guard let detail = detail, let originalDetail = originalDetail else {
            return true
        }
        
        if detail.images.isEmpty {
            return true
        }
        
        let isTitleChanged = detail.title != originalDetail.title
        let areImagesChanged = detail.images != originalDetail.images
        
        if !isTitleChanged && !areImagesChanged {
            return true
        }
        
        return false
    }
    
    public convenience init(record: Record) {
        self.init() // 기존 init 호출
        
        // Task를 이용해 파일 경로로부터 이미지를 비동기적으로 불러옵니다.
        Task {
            var loadedImages: [UIImage] = []
            for fileName in record.imageFileNames {
                if let image = await FileStoreManager.shared.loadImage(fileName: fileName) {
                    loadedImages.append(image)
                }
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 M월 d일"

            // 불러온 이미지와 Record의 정보로 UI 모델을 생성합니다.
            let detailModel = RecordDetailUIModel(
                title: record.flower.name, // 제목은 우선 꽃 이름으로 설정
                flowerName: record.flower.name,
                flowerMeaning: record.flower.meaning,
                location: "위치 정보 미정", // 위치 정보는 추후 추가
                date: dateFormatter.string(from: Date()),
                images: loadedImages
            )

            // @Published 프로퍼티를 업데이트하여 View에 반영합니다.
            self.detail = detailModel
            // 수정 기능을 위해 원본도 함께 저장해 둡니다.
            self.originalDetail = detailModel
        }
    }
  
    public init(id: UUID) {
           fetchRecordDetails(id: id)
       }
  
    // MARK: - Methods
    
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
    
    // MARK: - Image Handling
    
    func addImages(from items: [PhotosPickerItem]) {
        Task {
            var newImages: [UIImage] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    newImages.append(image)
                }
            }
            detail?.images.append(contentsOf: newImages)
        }
    }
    
    func deleteImage(_ image: UIImage) {
        detail?.images.removeAll { $0 == image }
    }
}

