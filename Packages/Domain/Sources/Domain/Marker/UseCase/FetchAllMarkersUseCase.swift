//
//  FetchAllMarkersUseCase.swift
//  Domain
//
//  Created by eunsong on 7/28/25.
//
import Dependencies
import Foundation

public struct FetchAllMarkersUseCase: Sendable {
    @Dependency(\.markerRepository) private var markerRepository

    public init() {}

    public func callAsFunction() async throws -> [Marker] {
        return try await markerRepository.fetchAll()
    }
}
