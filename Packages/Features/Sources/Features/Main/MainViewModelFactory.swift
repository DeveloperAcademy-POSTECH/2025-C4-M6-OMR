//
//  MainViewModelFactory.swift
//  Features
//
//  Created by eunsong on 7/28/25.
//
import Dependencies
import Domain
import Foundation

// MARK: - Factory Protocol
public protocol MainViewModelFactory: Sendable {
    @MainActor func create() -> MainViewModel
}

// MARK: - Live Factory with Dependencies
public struct LiveMainViewModelFactory: MainViewModelFactory {
    public init() {}

    @MainActor
    public func create() -> MainViewModel {
        // ✅ MoteApp의 withDependencies에서 자동 전파됨
        @Dependency(\.fetchMyRecordsUseCase) var fetchMyRecordsUseCase
        @Dependency(\.initializeAppDataUseCase) var initializeAppDataUseCase

        print("[Factory] Creating MainViewModel")
        print("  - FetchMyRecordsUseCase: \(type(of: fetchMyRecordsUseCase))")

        return MainViewModel(
            fetchMyRecordsUseCase: fetchMyRecordsUseCase,
            initializeAppDataUseCase: initializeAppDataUseCase
        )
    }
}
