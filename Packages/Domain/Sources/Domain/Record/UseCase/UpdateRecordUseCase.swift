//
//  UpdateRecordUseCase.swift
//  Domain
//
//  Created by eunsong on 7/20/25.
//

public struct UpdateRecordUseCase: Sendable {
    private let repo: RecordRepository

    public init(repo: RecordRepository) {
        self.repo = repo
    }

    /// 기존 Record 업데이트
    public func callAsFunction(
        _ record: Record
    ) async throws {
        try await repo.update(record)
    }
}
