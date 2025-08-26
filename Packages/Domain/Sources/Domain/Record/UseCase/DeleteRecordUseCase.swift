//
//  DeleteRecordUseCase.swift
//  Domain
//
//  Created by eunsong on 7/20/25.
//

import Dependencies

public struct DeleteRecordUseCase: Sendable {
    @Dependency(\.recordRepository) private var repo

    public init() { }

    /// Record 삭제
    public func callAsFunction(
        _ record: Record
    ) async throws {
        try await repo.delete(record)
    }
}
