//
//  FetchPublicRecordsUseCase.swift
//  Domain
//
//  Created by eunsong on 7/20/25.
//
import Dependencies
import Foundation

public struct FetchPublicRecordsUseCase: Sendable {
    @Dependency(\.recordRepository) private var recordRepository
    @Dependency(\.userRepository) private var userRepository
    @Dependency(\.markerRepository) private var markerRepository

    public init() { }

    /// 반경 내 공개된 타인 기록 조회
    public func callAsFunction(
        in filter: LocationFilter
    ) async throws -> [RecordDetail] {
        let records = try await recordRepository.fetchPublicRecords(in: filter)
        
        // TaskGroup을 사용해 병렬로 RecordDetail을 조회
        return try await withThrowingTaskGroup(of: RecordDetail.self) { group in
            var details: [RecordDetail] = []
            details.reserveCapacity(records.count)

            for record in records {
                group.addTask {
                    async let author = self.userRepository.fetch(by: record.authorID)
                    async let marker = self.markerRepository.fetch(by: record.markerTypeID)
                    
                    return try await RecordDetail(
                        record: record,
                        author: author,
                        marker: marker
                    )
                }
            }
            
            // 생성된 순서대로 결과 수집
            for try await detail in group {
                details.append(detail)
            }
            
            return details
        }
    }
}
