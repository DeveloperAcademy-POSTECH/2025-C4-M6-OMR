//
//  AppDI.swift
//  MoteApp
//
//  Created by eunsong on 7/15/25.
//

import Dependencies
import Foundation
import SwiftData
import Domain   // DI 키 & 프로토콜
import Data     // DefaultRecordRepository 등 구현체
import Core
import Features
import SwiftUI  // View 확장

public struct AppDI {
    // SwiftData 모델 컨테이너 & DataSource
    internal static let modelContext     = ModelContext(AppModelContainer.shared)
    internal static let localRecordDS    = LocalRecordDataSource(container: AppModelContainer.shared)
    internal static let remoteRecordDS   = RemoteRecordDatasource()
    internal static let userLocalDS      = UserLocalDatasource(modelContext: modelContext)
    internal static let markerLocalDS    = MarkerLocalDatasource(modelContext: modelContext)

    // Repository 구현체 라이브값
    public static let recordRepositoryLiveValue: RecordRepository = DefaultRecordRepository(
        local:                  localRecordDS,
        remote:                 remoteRecordDS,
        currentUserIDProvider:  { UUID() }
    )
    public static let userRepositoryLiveValue: UserRepository = DefaultUserRepository(
        local: userLocalDS
    )
    public static let markerRepositoryLiveValue: MarkerRepository = DefaultMarkerRepository(
        local: markerLocalDS
    )
}

// MARK: - SwiftUI View Extension for DI

extension View {
    /// 앱 전체 의존성을 이 뷰 컨텍스트에 주입합니다.
    func injectAppDependencies() -> some View {
        withDependencies {
            $0.recordRepository = AppDI.recordRepositoryLiveValue
            $0.userRepository   = AppDI.userRepositoryLiveValue
            $0.markerRepository = AppDI.markerRepositoryLiveValue
        } operation: {
            self
        }
    }
}
