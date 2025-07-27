import CoreLocation
import Dependencies
import Domain
import Foundation

// MARK: - Factory Keys
public struct ARCameraViewModelFactoryKey: DependencyKey {
    public static let liveValue: ARCameraViewModelFactory =
        LiveARCameraViewModelFactory()
}

// MARK: - DependencyValues Extension
extension DependencyValues {
    public var arCameraViewModelFactory: ARCameraViewModelFactory {
        get { self[ARCameraViewModelFactoryKey.self] }
        set { self[ARCameraViewModelFactoryKey.self] = newValue }
    }
}
