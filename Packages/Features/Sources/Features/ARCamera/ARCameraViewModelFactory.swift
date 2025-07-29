import CoreLocation
import Dependencies
import Domain
import Foundation

// MARK: - Factory Protocol
@MainActor
public protocol ARCameraViewModelFactory: Sendable {
    @available(iOS 18.0, *)
    func create(
        location: CLLocation,
        bottomSheetCoordinator: BottomSheetCoordinator
    ) -> ARCameraViewModel
}

// MARK: - Live Factory with Dependencies
public struct LiveARCameraViewModelFactory: ARCameraViewModelFactory {
    @available(iOS 18.0, *)
    @MainActor
    public func create(
        location: CLLocation,
        bottomSheetCoordinator: BottomSheetCoordinator
    ) -> ARCameraViewModel {
        // Use @Dependency to get the current context's dependencies
        @Dependency(\.fetchMyRecordsUseCase) var fetchMyRecordsUseCase
        @Dependency(\.saveRecordUseCase) var saveRecordUseCase
        @Dependency(\.initializeAppDataUseCase) var initializeAppDataUseCase
        @Dependency(\.fetchAllMarkersUseCase) var fetchAllMarkersUseCase
        // Debug logging
        let _ = print("[Factory] Creating ARCameraViewModel with use cases")

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
