//
//  FetchRecordDetailUseCase.swift
//  Domain
//
//  Created by eunsong on 7/20/25.
//
import Foundation

public struct FetchRecordDetailUseCase: Sendable {
    private let recordRepository: RecordRepository
    private let userRepository: UserRepository
    private let markerRepository: MarkerRepository

    public init(
        recordRepository: RecordRepository,
        userRepository: UserRepository,
        markerRepository: MarkerRepository
    ) {
        self.recordRepository = recordRepository
        self.userRepository = userRepository
        self.markerRepository = markerRepository
    }

    /// 단건 상세 조회
    public func callAsFunction(
        id: UUID
    ) async throws -> RecordDetail {
        let record = try await recordRepository.fetchRecordDetail(id: id)
        
        async let author = userRepository.fetch(by: record.authorID)
        async let marker = markerRepository.fetch(by: record.markerTypeID)
        
        return try await .init(
            record: record,
            author: author,
            marker: marker
        )
    }
}