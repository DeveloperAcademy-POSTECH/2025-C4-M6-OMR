//
//  MainViewModelFactory.swift
//  Features
//
//  Created by eunsong on 7/28/25.
//
import Dependencies
import Foundation

// MARK: - Factory Protocol
@MainActor
public protocol MainViewModelFactory: Sendable {
    func create() -> MainViewModel
}

// MARK: - Live Factory with Dependencies
public struct LiveMainViewModelFactory: MainViewModelFactory {
    @MainActor
    public func create() -> MainViewModel {
        @Dependency(\.fetchMyRecordsUseCase) var fetchMyRecordsUseCase
        @Dependency(\.initializeAppDataUseCase) var initializeAppDataUseCase

        // Debug logging
        let _ = print("[Factory] Creating MainViewModel with use cases")

        return MainViewModel(
            fetchMyRecordsUseCase: fetchMyRecordsUseCase,
            initializeAppDataUseCase: initializeAppDataUseCase
        )
    }
}
