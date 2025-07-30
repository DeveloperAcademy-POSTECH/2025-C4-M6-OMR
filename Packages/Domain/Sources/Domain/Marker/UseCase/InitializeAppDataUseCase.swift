import Dependencies
//
//  InitializeAppDataUseCase.swift
//  Domain
//
//  Created by eunsong on 7/28/25.
//
import Foundation

public struct InitializeAppDataUseCase: Sendable {
    @Dependency(\.userRepository) private var userRepository
    @Dependency(\.markerRepository) private var markerRepository

    public init() { }

    public func callAsFunction() async throws {
        try await userRepository.initializeDefaultUser()
        try await markerRepository.initializeDefaultMarkers()
        let markers = try await markerRepository.fetchAll()
        print("InitializeAppDataUseCase Markers: \(markers)")
    }
}
