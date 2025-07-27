//
//  BottomSheetCoordinator.swift
//  Features
//
//  Created by eunsong on 7/26/25.
//

import Combine
import SwiftUI

@MainActor
public class BottomSheetCoordinator: ObservableObject {

    // MARK: - Published Properties
    @Published var activeSheet: BottomSheetType?

    // MARK: - Sheet Data
    @Published var selectedRecord: ARRecordModel?
    @Published var selectedFlower: FlowerModel?
    @Published var flowerForSave: ARFlower?

    // MARK: - ViewModels
    @Published var flowerSelectionViewModel = FlowerSelectionViewModel()
    @Published var recordDetailViewModel: RecordDetailViewModel?
    @Published var saveSheetViewModel: RecordSaveSheetViewModel?

    // MARK: - Delegate
    weak var delegate: BottomSheetCoordinatorDelegate?
    
    var onCancelPlacement: () -> Void = {}

    init() {
        setupFlowerSelectionCallback()
    }
    
    func cancelPlacement() {
        onCancelPlacement()
        dismissSheet()
    }

    private func setupFlowerSelectionCallback() {
        print("🔧 FlowerSelection 콜백 설정 중...")
        flowerSelectionViewModel.onFlowerSelected = { [weak self] flower in
            print("🔧 FlowerSelection 콜백 호출됨: \(flower.name)")
            self?.handleFlowerSelection(flower)
        }
        print("🔧 FlowerSelection 콜백 설정 완료")
    }

    // MARK: - Public Methods
    func showFlowerSelection() {
        print("📱 showFlowerSelection 호출됨")
        activeSheet = .flowerSelection
        print("📱 activeSheet = .flowerSelection 설정됨")
    }

    func showRecordDetail(record: ARRecordModel) {
        print("📱 showRecordDetail 호출됨: \(record.title)")
        selectedRecord = record

        // 기본 RecordDetailViewModel 생성 후 데이터 설정
        let viewModel = RecordDetailViewModel()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월 d일"

        // 기존 방식과 동일하게 Mock 이미지 생성
        let dummyPhotos = ["photo.artframe", "camera.fill", "tree.fill"]
        let images = dummyPhotos.compactMap { UIImage(systemName: $0) }

        // ARRecordModel의 데이터를 RecordDetailUIModel로 변환
        let mockDetail = RecordDetailUIModel(
            title: record.title.isEmpty ? "제목 없음" : record.title,
            flowerName: "프리지아",
            flowerMeaning: "영원한 사랑",
            location: "포항공과대학교",
            date: dateFormatter.string(from: record.createdDate),
            images: images
        )

        viewModel.setDetail(mockDetail)
        recordDetailViewModel = viewModel
        activeSheet = .recordDetail
        print("📱 RecordDetail 시트 설정 완료")
    }

    func showSaveSheet(
        info: RecordSaveSheetInfo,
        onSave: @escaping (FinalRecordData) -> Void,
        onCancel: @escaping () -> Void
    ) {
        print("📱 showSaveSheet 호출됨: \(info.flower.name)")

        let viewModel = RecordSaveSheetViewModel(
            info: info,
            onSave: { [weak self] finalRecord in
                onSave(finalRecord)
                self?.dismissSheet()
            }
        )
        self.saveSheetViewModel = viewModel
        self.onCancelPlacement = onCancel
        self.activeSheet = .saveSheet
        print("📱 SaveSheet 설정 ���료")
    }

    func dismissSheet() {
        print("📱 dismissSheet 호출됨")
        activeSheet = nil
        clearSheetData()
        print("📱 시트 해제 완료")
    }

    // MARK: - Private Methods
    private func handleFlowerSelection(_ flower: FlowerModel) {
        print("🌻 handleFlowerSelection 호출됨: \(flower.name)")
        print("🌻 delegate: \(delegate != nil ? "있음" : "없음")")

        selectedFlower = flower
        delegate?.didSelectFlower(flower)
        print("🌻 delegate?.didSelectFlower 호출 완료")

        dismissSheet()
        print("🌻 시트 해제 완료")
    }

    private func clearSheetData() {
        selectedRecord = nil
        selectedFlower = nil
        flowerForSave = nil
        recordDetailViewModel = nil
        saveSheetViewModel = nil
    }
}
