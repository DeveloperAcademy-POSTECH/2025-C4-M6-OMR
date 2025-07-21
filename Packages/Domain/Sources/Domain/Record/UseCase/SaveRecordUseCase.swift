//
//  SaveRecordUseCase.swift
//  Domain
//
//  Created by eunsong on 7/20/25.
//

public struct SaveRecordUseCase: Sendable {
    private let repo: RecordRepository

    public init(repo: RecordRepository) {
        self.repo = repo
    }

    /// 새 Record 저장
    public func callAsFunction(
        _ record: Record
    ) async throws {
        try await repo.save(record)
    }
}
