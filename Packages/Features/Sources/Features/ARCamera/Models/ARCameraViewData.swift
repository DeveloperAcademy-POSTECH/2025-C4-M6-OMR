import Foundation
import SwiftUI

// MARK: - ARCameraMode
public enum ARCameraMode {
    case normal
    case placement
}

// MARK: - ARCameraViewData
public struct ARCameraViewData {
    public var cameraMode: ARCameraMode = .normal
    public var statusMessage: String = ""
    public var isShowingRecordDetailSheet: Bool = false
    public var selectedRecord: ARRecordModel? = nil
    public var isShowingFlowerSelectionSheet: Bool = false
    public var isShowingSaveSheet: Bool = false
    public var isPlacementConfirmed: Bool = false
    public var selectedFlower: ARFlower? = nil

    public init(
        cameraMode: ARCameraMode = .normal,
        statusMessage: String = "",
        isShowingRecordDetailSheet: Bool = false,
        selectedRecord: ARRecordModel? = nil,
        isShowingFlowerSelectionSheet: Bool = false,
        isShowingSaveSheet: Bool = false,
        isPlacementConfirmed: Bool = false,
        selectedFlower: ARFlower? = nil
    ) {
        self.cameraMode = cameraMode
        self.statusMessage = statusMessage
        self.isShowingRecordDetailSheet = isShowingRecordDetailSheet
        self.selectedRecord = selectedRecord
        self.isShowingFlowerSelectionSheet = isShowingFlowerSelectionSheet
        self.isShowingSaveSheet = isShowingSaveSheet
        self.isPlacementConfirmed = isPlacementConfirmed
        self.selectedFlower = selectedFlower
    }
}
