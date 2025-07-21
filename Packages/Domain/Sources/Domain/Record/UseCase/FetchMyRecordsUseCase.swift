//
//  FetchMyRecordsUseCase.swift
//  Domain
//
//  Created by eunsong on 7/20/25.
//
import Foundation

public struct FetchMyRecordsUseCase: Sendable {
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

    /// 내 기록 조회 (필터가 없으면 전체, 있으면 반경 내)
    public func callAsFunction(
        in filter: LocationFilter? = nil
    ) async throws -> [RecordDetail] {
        let records = try await recordRepository.fetchMyRecords(in: filter)
        
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