//
//  AppDI.swift
//  MoteApp
//
//  Created by eunsong on 7/15/25.
//
import Dependencies
import Foundation
import SwiftData
import Domain
import Data
import Core
import Features

public struct AppDI {
    internal static let modelContext = ModelContext(AppModelContainer.shared)
    internal static let localRecordDS = LocalRecordDataSource(container: AppModelContainer.shared)
    internal static let remoteRecordDS = RemoteRecordDatasource()
    internal static let userLocalDS = UserLocalDatasource(modelContext: modelContext)
    internal static let userRepo = DefaultUserRepository(local: userLocalDS)
    internal static let markerLocalDS = MarkerLocalDatasource(modelContext: modelContext)
    internal static let markerRepo = DefaultMarkerRepository(local: markerLocalDS)

    public static func registerDependencies() {
        // Register all application-level dependencies here
    }
}

// MARK: - RecordUseCase DI

private enum FetchPublicRecordsUseCaseKey: DependencyKey {
    static var liveValue: FetchPublicRecordsUseCase {
        let recordRepo  = DefaultRecordRepository(local: AppDI.localRecordDS, remote: AppDI.remoteRecordDS) {
            return UUID()
        }
        return FetchPublicRecordsUseCase(
            recordRepository: recordRepo,
            userRepository: AppDI.userRepo,
            markerRepository: AppDI.markerRepo
        )
    }
}

private enum FetchMyRecordsUseCaseKey: DependencyKey {
    static var liveValue: FetchMyRecordsUseCase {
        let recordRepo  = DefaultRecordRepository(local: AppDI.localRecordDS, remote: AppDI.remoteRecordDS) {
            return UUID()
        }
        return FetchMyRecordsUseCase(
            recordRepository: recordRepo,
            userRepository: AppDI.userRepo,
            markerRepository: AppDI.markerRepo
        )
    }
}

private enum FetchRecordDetailUseCaseKey: DependencyKey {
    static var liveValue: FetchRecordDetailUseCase {
        let recordRepo  = DefaultRecordRepository(local: AppDI.localRecordDS, remote: AppDI.remoteRecordDS) {
            return UUID()
        }
        return FetchRecordDetailUseCase(
            recordRepository: recordRepo,
            userRepository: AppDI.userRepo,
            markerRepository: AppDI.markerRepo
        )
    }
}

extension DependencyValues {
    var fetchPublicRecordsUseCase: FetchPublicRecordsUseCase {
        get { self[FetchPublicRecordsUseCaseKey.self] }
        set { self[FetchPublicRecordsUseCaseKey.self] = newValue }
    }
    var fetchMyRecordsUseCase: FetchMyRecordsUseCase {
        get { self[FetchMyRecordsUseCaseKey.self] }
        set { self[FetchMyRecordsUseCaseKey.self] = newValue }
    }
    var fetchRecordDetailUseCase: FetchRecordDetailUseCase {
        get { self[FetchRecordDetailUseCaseKey.self] }
        set { self[FetchRecordDetailUseCaseKey.self] = newValue }
    }
}
