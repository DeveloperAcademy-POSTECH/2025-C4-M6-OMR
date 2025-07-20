//
//  RecordDetailViewModel.swift.swift
//  Features
//
//  Created by Henry on 7/19/25.
//

import SwiftUI
import Combine
import Domain
import PhotosUI

@MainActor
public final class RecordDetailViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var flowerName: String = ""
    @Published var flowerMeaning: String = ""
    @Published var location: String = ""
    @Published var date: String = ""
    @Published var title: String = ""
    @Published var selectedImages: [UIImage] = []
    
    @Published var isEditing: Bool = false
    
    // MARK: - Properties
    // TODO: 나중에 실제 UseCase를 주입
    // private let fetchDetailUseCase: FetchRecordDetailUseCase
    
    // MARK: - Initialization
    
    // ViewModel이 생성될 때 목업 데이터를 바로 로드합니다.
    public init() {
        fetchRecordDetails()
    }
    
    // MARK: - Methods
    func fetchRecordDetails() {
        // 지금은 UI 개발을 위해 임시 목업 데이터를 생성
        // 추후, 실제 UseCase를 통해 서버에서 데이터를 가져오도록 변경 예정
        
        // 1. 임시 텍스트 데이터 생성
        self.flowerName = "프리지아"
        self.flowerMeaning = "영원한 사랑"
        self.location = "포항공과대학교"
        self.title = "\(self.location)에서"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월 d일"
        self.date = dateFormatter.string(from: Date())
        
        let dummyPhotos = ["photo", "photo.fill", "photo.on.rectangle.angled", "photo.artframe"]
        self.selectedImages = dummyPhotos.compactMap { UIImage(systemName: $0) }
        
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
            
            withAnimation {
                selectedImages.append(contentsOf: newImages)
            }
        }
    }
    
    func deleteImage(_ image: UIImage) {
        withAnimation {
            selectedImages.removeAll { $0 == image }
        }
    }
    
    func editButtonTapped() {
        isEditing = true
    }
    
    
    func saveButtonTapped() {
        // TODO: 변경 내용을 저장 하는 로직 추가
        print("저장할 제목: \(title)")
        // isEditing이 false로 바뀌면, 현재 title 값을 저장하는 로직 추가
        isEditing = false
    }
}


// 빌드를 위해 임시 RecordDetailViewModel 생성자 추가
public extension RecordDetailViewModel {
    convenience init(summary: ObjectSummary) {
        self.init()
        
        self.flowerName = "프리지아"
        self.flowerMeaning = "영원한 사랑"
        self.location = "포항공과대학교"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월 d일"
        self.date = dateFormatter.string(from: Date())
        
        // 임시 이미지
        let dummyPhotos = ["photo", "photo.fill", "photo.on.rectangle.angled", "photo.artframe"]
        self.selectedImages = dummyPhotos.compactMap { UIImage(systemName: $0) }
    }
}
