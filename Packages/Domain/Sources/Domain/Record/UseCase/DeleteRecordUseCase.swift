//
//  DeleteRecordUseCase.swift
//  Domain
//
//  Created by eunsong on 7/20/25.
//

public struct DeleteRecordUseCase: Sendable {
    private let repo: RecordRepository

    public init(repo: RecordRepository) {
        self.repo = repo
    }

    /// Record 삭제
    public func callAsFunction(
        _ record: Record
    ) async throws {
        try await repo.delete(record)
    }
}
