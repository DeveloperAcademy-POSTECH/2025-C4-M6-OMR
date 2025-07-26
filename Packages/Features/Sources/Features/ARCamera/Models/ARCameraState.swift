//
//  ARCameraState.swift
//  Features
//
//  Created by eunsong on 7/26/25.
//
import Foundation

@MainActor
class ARCameraState: ObservableObject {
    // MARK: - UI State
    @Published var statusMessage: String = "AR 세션을 시작합니다..."
    @Published var cameraMode: ARCameraMode = .normal
    @Published var isPlacementConfirmed: Bool = false
    @Published var isARSessionActive: Bool = false

    // MARK: - Loading States
    @Published var isLoadingRecords: Bool = false
    @Published var isSavingRecord: Bool = false

    // MARK: - Error State
    @Published var errorMessage: String?

    // MARK: - Computed Properties
    var canConfirmPlacement: Bool {
        cameraMode == .placement && !isPlacementConfirmed
    }

    var canSaveRecord: Bool {
        isPlacementConfirmed && !isSavingRecord
    }

    var showSaveButton: Bool {
        cameraMode == .placement && isPlacementConfirmed
    }

    // MARK: - State Management Methods
    func reset() {
        statusMessage = "AR 세션을 시작합니다..."
        cameraMode = .normal
        isPlacementConfirmed = false
        isLoadingRecords = false
        isSavingRecord = false
        errorMessage = nil
    }

    func setMode(_ mode: ARCameraMode) {
        cameraMode = mode
        isPlacementConfirmed = false

        switch mode {
        case .normal:
            statusMessage = "주변 기록들을 확인해보세요."
        case .placement:
            statusMessage = "배치할 꽃을 선택하세요."
        }
    }

    func showError(_ error: Error) {
        errorMessage = error.localizedDescription
        statusMessage = "오류가 발생했습니다: \(error.localizedDescription)"
    }

    func clearError() {
        errorMessage = nil
    }
}
