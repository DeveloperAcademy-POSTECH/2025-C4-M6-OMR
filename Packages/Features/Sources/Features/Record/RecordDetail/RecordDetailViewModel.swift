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
        
        // 사진이 하나도 없으면 비활성화
        if detail.images.isEmpty {
            return true
        }
        
        // 원본과 현재 상태가 동일하면 (변경사항이 없으면) 비활성화
        let isTitleChanged = detail.title != originalDetail.title
        let areImagesChanged = detail.images != originalDetail.images
        
        if !isTitleChanged && !areImagesChanged {
            return true
        }
        
        return false
    }
    
    // MARK: - Initialization
    
    public init() {
        fetchRecordDetails()
    }
    
    // MARK: - Methods
    
    func fetchRecordDetails() {
        // ---  UseCase를 호출하고 Entity를 매핑하는 코드로 대체 ---
        
        // 임시 데이터 생성
        let location = "포항공과대학교"
        let title = "\(location)에서"
        let dummyPhotos = ["photo.artframe", "camera.fill", "tree.fill"]
        let images = dummyPhotos.compactMap { UIImage(systemName: $0) }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월 d일"
        
        let mockDetail = RecordDetailUIModel(
            title: title,
            flowerName: "프리지아",
            flowerMeaning: "영원한 사랑",
            location: location,
            date: dateFormatter.string(from: Date()),
            images: images
        )
        
        self.detail = mockDetail
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


public extension RecordDetailViewModel {
    convenience init(summary: ObjectSummary) {
        self.init()
        // TODO: summary 객체로부터 실제 데이터를 받아와 프로퍼티를 채우는 로직 구현
    }
}
