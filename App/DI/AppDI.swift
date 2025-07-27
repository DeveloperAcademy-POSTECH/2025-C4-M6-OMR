import Core
import Data
import Dependencies
import Domain
import Features
import Foundation
import SwiftData
import SwiftUI

public struct AppDI {
    // MARK: - SwiftData & DataSource Setup

    internal static let modelContext = ModelContext(AppModelContainer.shared)
    internal static let localRecordDS = LocalRecordDataSource(
        container: AppModelContainer.shared
    )
    internal static let remoteRecordDS = RemoteRecordDatasource()
    internal static let userLocalDS = UserLocalDatasource(
        modelContext: modelContext
    )
    internal static let markerLocalDS = MarkerLocalDatasource(
        modelContext: modelContext
    )

    // MARK: - Repository Live Values

    public static let recordRepository: RecordRepository =
        DefaultRecordRepository(
            local: localRecordDS,
            remote: remoteRecordDS,
            currentUserIDProvider: { try await getCurrentUserID() }
        )

    public static let userRepository: UserRepository = DefaultUserRepository(
        local: userLocalDS
    )

    public static let markerRepository: MarkerRepository =
        DefaultMarkerRepository(
            local: markerLocalDS
        )

    // MARK: - Helper Methods

    private static func getCurrentUserID() async throws -> UUID {
        UUID(uuidString: "00000000-0000-0000-0000-000000000000") ?? UUID()
    }

    // MARK: - Setup Method

    public static func setup() {
        // 1. Configure Features module dependencies
        Task { @MainActor in
            let featuresDeps = FeaturesDependencies(
                recordRepository: recordRepository,
                userRepository: userRepository,
                markerRepository: markerRepository
            )
            FeaturesDependencies.configure(with: featuresDeps)
        }

        // 2. Register global swift-dependencies (for non-navigation contexts)
        withDependencies {
            $0.recordRepository = recordRepository
            $0.userRepository = userRepository
            $0.markerRepository = markerRepository
        } operation: {
            // Empty - just setting up
        }
    }
}
