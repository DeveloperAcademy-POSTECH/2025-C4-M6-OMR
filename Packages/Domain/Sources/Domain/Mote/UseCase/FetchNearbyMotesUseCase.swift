//
//  FetchNearbyMotesUseCase.swift
//  Domain
//
//  Created by eunsong on 7/15/25.
//

import Foundation

public struct FetchNearbyMotesUseCase: Sendable {
    let repository: MoteRepository

    public init(repository: MoteRepository) {
        self.repository = repository
    }

    public func callAsFunction(center: Location, radius: Double) async throws -> [Mote] {
        try await repository.fetchNearbyMotes(center: center, radius: radius)
    }
}
