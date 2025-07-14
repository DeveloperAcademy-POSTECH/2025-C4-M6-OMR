//
//  FetchMyMotesUseCase.swift
//  Domain
//
//  Created by eunsong on 7/15/25.
//

import Foundation

public struct FetchMyMotesUseCase: Sendable {
    let repository: MoteRepository

    public init(repository: MoteRepository) {
        self.repository = repository
    }

    public func callAsFunction() async throws -> [Mote] {
        try await repository.fetchMyMotes()
    }
}
