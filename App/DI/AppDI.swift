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

    // 메인 큐용 ModelContext (UI 및 동기 작업용)
    @MainActor
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
    internal static let markderDefaultDS = DefaultMarkerDataSource()

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
            local: markerLocalDS,
            defaultDataSource: markderDefaultDS
        )

    // MARK: - Helper Methods

    private static func getCurrentUserID() async throws -> UUID {
        UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID()
    }

    // MARK: - Setup Method

    public static func setup() {
        print("[AppDI] Setup completed - Repository instances created")
        print("  - RecordRepository: \(type(of: recordRepository))")
        print("  - UserRepository: \(type(of: userRepository))")
        print("  - MarkerRepository: \(type(of: markerRepository))")

        // ✅ FeaturesDependencies 관련 코드 모두 제거
        // withDependencies가 자동으로 전파하므로 별도 설정 불필요
    }
}
