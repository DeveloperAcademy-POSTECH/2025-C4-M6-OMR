//
//  UpdateRecordUseCase.swift
//  Domain
//
//  Created by eunsong on 7/20/25.
//

import Dependencies

public struct UpdateRecordUseCase: Sendable {
    @Dependency(\.recordRepository) private var repo

    public init() { }

    /// 기존 Record 업데이트
    public func callAsFunction(
        _ record: Record
    ) async throws {
        try await repo.update(record)
    }
}
