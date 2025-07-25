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
    
    // MARK: - Initialization
    public init() {
        // 기본 초기화 시에는 임시 데이터 세팅하거나 안 할 수 있음
    }
    
    convenience init(summary: ObjectSummary) {
        self.init()
        fetchRecordDetails(id: summary.id)
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

