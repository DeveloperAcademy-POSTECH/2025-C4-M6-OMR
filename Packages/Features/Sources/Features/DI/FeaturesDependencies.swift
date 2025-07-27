import Dependencies
import Domain
import Foundation

// MARK: - Features Module Dependencies Container
// This provides a way to inject dependencies from the App module
public struct FeaturesDependencies {
    public let recordRepository: RecordRepository
    public let userRepository: UserRepository
    public let markerRepository: MarkerRepository
    
    public init(
        recordRepository: RecordRepository,
        userRepository: UserRepository,
        markerRepository: MarkerRepository
    ) {
        self.recordRepository = recordRepository
        self.userRepository = userRepository
        self.markerRepository = markerRepository
    }
    
    // Static holder for injected dependencies
    private static var _current: FeaturesDependencies?
    
    public static var current: FeaturesDependencies {
        guard let deps = _current else {
            fatalError("FeaturesDependencies not configured. Call FeaturesDependencies.configure() from your App module.")
        }
        return deps
    }
    
    // Configuration method to be called from App module
    public static func configure(with dependencies: FeaturesDependencies) {
        _current = dependencies
    }
}