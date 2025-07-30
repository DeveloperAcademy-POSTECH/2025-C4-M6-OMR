//
//  FetchRecordDetailUseCase.swift
//  Domain
//
//  Created by eunsong on 7/20/25.
//
import Dependencies
import Foundation

public struct FetchRecordDetailUseCase: Sendable {
    @Dependency(\.recordRepository) private var recordRepository
    @Dependency(\.userRepository) private var userRepository
    @Dependency(\.markerRepository) private var markerRepository

    public init() { }

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