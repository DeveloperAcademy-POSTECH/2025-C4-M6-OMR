import CoreLocation
import Dependencies
import Domain
import Foundation

// MARK: - Factory Protocol

public protocol ARCameraViewModelFactory: Sendable {
    @available(iOS 18.0, *)
    @MainActor
    func create(
        location: CLLocation,
        bottomSheetCoordinator: BottomSheetCoordinator
    ) -> ARCameraViewModel
}

// MARK: - Live Factory with Dependencies
public struct LiveARCameraViewModelFactory: ARCameraViewModelFactory {
    public init() {}

    @available(iOS 18.0, *)
    @MainActor
    public func create(
        location: CLLocation,
        bottomSheetCoordinator: BottomSheetCoordinator
    ) -> ARCameraViewModel {
        // ✅ MoteApp의 withDependencies에서 자동 전파됨
        @Dependency(\.fetchMyRecordsUseCase) var fetchMyRecordsUseCase
        @Dependency(\.saveRecordUseCase) var saveRecordUseCase
        @Dependency(\.initializeAppDataUseCase) var initializeAppDataUseCase
        @Dependency(\.fetchAllMarkersUseCase) var fetchAllMarkersUseCase

        print("[Factory] Creating ARCameraViewModel")
        print("  - SaveRecordUseCase: \(type(of: saveRecordUseCase))")

        return ARCameraViewModel(
            fetchMyRecordsUseCase: fetchMyRecordsUseCase,
            saveRecordUseCase: saveRecordUseCase,
            initializeAppDataUseCase: initializeAppDataUseCase,
            fetchAllMarkersUseCase: fetchAllMarkersUseCase,
            location: location,
            bottomSheetCoordinator: bottomSheetCoordinator
        )
    }
}
