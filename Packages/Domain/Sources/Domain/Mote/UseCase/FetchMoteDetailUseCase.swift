//
//  FetchMoteDetailUseCase.swift
//  Domain
//
//  Created by eunsong on 7/15/25.
//
import Foundation

public struct FetchMoteDetailUseCase: Sendable {
    let repository: MoteRepository

    public init(repository: MoteRepository) {
        self.repository = repository
    }

    public func callAsFunction(id: UUID) async throws -> Mote {
        try await repository.fetchMoteDetail(id: id)
    }
}
