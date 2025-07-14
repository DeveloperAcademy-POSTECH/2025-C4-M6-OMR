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
    public static func registerDependencies() {
        // Register all application-level dependencies here
    }
}

// MARK: - MoteUseCase DI

private enum FetchNearbyMotesUseCaseKey: DependencyKey {
    static var liveValue: FetchNearbyMotesUseCase {
        let modelContext = ModelContext(AppModelContainer.shared)
        let local = LocalMoteDatasource(modelContext: modelContext)
        let remote = RemoteMoteDatasource()
        let repo  = DefaultMoteRepository(local: local, remote: remote) {
            // 임시: 현재 로그인 유저 ID를 무명 UUID로 대체
            return UUID()
        }
        return FetchNearbyMotesUseCase(repository: repo)
    }
}

private enum FetchMyMotesUseCaseKey: DependencyKey {
    static var liveValue: FetchMyMotesUseCase {
        let modelContext = ModelContext(AppModelContainer.shared)
        let local = LocalMoteDatasource(modelContext: modelContext)
        let remote = RemoteMoteDatasource()
        let repo  = DefaultMoteRepository(local: local, remote: remote) {
            return UUID()
        }
        return FetchMyMotesUseCase(repository: repo)
    }
}

private enum FetchMoteDetailUseCaseKey: DependencyKey {
    static var liveValue: FetchMoteDetailUseCase {
        let modelContext = ModelContext(AppModelContainer.shared)
        let local = LocalMoteDatasource(modelContext: modelContext)
        let remote = RemoteMoteDatasource()
        let repo  = DefaultMoteRepository(local: local, remote: remote) {
            return UUID()
        }
        return FetchMoteDetailUseCase(repository: repo)
    }
}

extension DependencyValues {
    var fetchNearbyMotesUseCase: FetchNearbyMotesUseCase {
        get { self[FetchNearbyMotesUseCaseKey.self] }
        set { self[FetchNearbyMotesUseCaseKey.self] = newValue }
    }
    var fetchMyMotesUseCase: FetchMyMotesUseCase {
        get { self[FetchMyMotesUseCaseKey.self] }
        set { self[FetchMyMotesUseCaseKey.self] = newValue }
    }
    var fetchMoteDetailUseCase: FetchMoteDetailUseCase {
        get { self[FetchMoteDetailUseCaseKey.self] }
        set { self[FetchMoteDetailUseCaseKey.self] = newValue }
    }
}
