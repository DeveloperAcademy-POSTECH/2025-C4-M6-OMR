import CoreLocation
import Dependencies
import Domain
import Foundation

// MARK: - Factory Keys
public struct ARCameraViewModelFactoryKey: DependencyKey {
    public static let liveValue: ARCameraViewModelFactory =
        LiveARCameraViewModelFactory()
}

public struct FlowerSelectionViewModelFactoryKey: DependencyKey {
    public static let liveValue: FlowerSelectionViewModelFactory =
        LiveFlowerSelectionViewModelFactory()
}

public struct BottomSheetCoordinatorFactoryKey: DependencyKey {
    public static let liveValue: BottomSheetCoordinatorFactory =
        LiveBottomSheetCoordinatorFactory()
}

// MARK: - DependencyValues Extension
extension DependencyValues {
    public var arCameraViewModelFactory: ARCameraViewModelFactory {
        get { self[ARCameraViewModelFactoryKey.self] }
        set { self[ARCameraViewModelFactoryKey.self] = newValue }
    }

    public var flowerSelectionViewModelFactory: FlowerSelectionViewModelFactory
    {
        get { self[FlowerSelectionViewModelFactoryKey.self] }
        set { self[FlowerSelectionViewModelFactoryKey.self] = newValue }
    }

    public var bottomSheetCoordinatorFactory: BottomSheetCoordinatorFactory {
        get { self[BottomSheetCoordinatorFactoryKey.self] }
        set { self[BottomSheetCoordinatorFactoryKey.self] = newValue }
    }
}

//// MARK: - MainViewModelFactory DI
public struct MainViewModelFactoryKey: DependencyKey {
    public static let liveValue: MainViewModelFactory =
        LiveMainViewModelFactory()
}

extension DependencyValues {
    public var mainViewModelFactory: MainViewModelFactory {
        get { self[MainViewModelFactoryKey.self] }
        set { self[MainViewModelFactoryKey.self] = newValue }
    }
}
