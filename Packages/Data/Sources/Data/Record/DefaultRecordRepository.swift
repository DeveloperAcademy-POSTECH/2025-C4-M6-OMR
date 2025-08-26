//
//  DefaultRecordRepository.swift
//  Data
//
//  Created by eunsong on 7/15/25.
//

import Domain
import Foundation

//public final class DefaultRecordRepository: RecordRepository {
//    public init() { }
//
//    public func fetchMyRecords(in filter: LocationFilter?) async throws -> [Record] {
//        print("✅ DefaultRecordRepository.fetchMyRecords called")
//        return [] // 빈 배열 반환 (DI 연결 테스트용)
//    }
//
//    public func fetchRecordDetail(id: UUID) async throws -> Record {
//        print("✅ DefaultRecordRepository.fetchRecordDetail called")
//        throw RecordRepositoryError.notFound
//    }
//
//    public func fetchPublicRecords(in filter: LocationFilter) async throws -> [Record] {
//        print("✅ DefaultRecordRepository.fetchPublicRecords called")
//        return []
//    }
//
//    public func save(_ record: Record) async throws {
//        print("✅ DefaultRecordRepository.save called: \(record.id)")
//    }
//
//    public func update(_ record: Record) async throws {
//        print("✅ DefaultRecordRepository.update called: \(record.id)")
//    }
//
//    public func delete(_ record: Record) async throws {
//        print("✅ DefaultRecordRepository.delete called: \(record.id)")
//    }
//}

// 기본 RecordRepository 구현체
public final class DefaultRecordRepository: RecordRepository {
    private let local: LocalRecordDataSource
    private let remote: RemoteRecordDatasource  // TODO: 원격 데이터소스 구현 시 실제 타입으로 변경
    private let currentUserIDProvider: @Sendable () async throws -> UUID

    public init(
        local: LocalRecordDataSource,
        remote: RemoteRecordDatasource,
        currentUserIDProvider: @Sendable @escaping () async throws -> UUID
    ) {
        self.local = local
        self.remote = remote
        self.currentUserIDProvider = currentUserIDProvider
    }

    // MARK: - Read

    /// 내 Record들을 조회 (필터: 전체 or 반경)
    public func fetchMyRecords(
        in filter: LocationFilter?
    ) async throws -> [Record] {
        print("DefaultRecordRepository \(filter?.center)")
        let currentUserID = try await currentUserIDProvider()
        let request = RecordFetchRequest(
            userId: currentUserID,
            onlyPublic: false, // 내 기록은 공개여부 상관없�� 모두
            centerLatitude: filter?.center.latitude,
            centerLongitude: filter?.center.longitude,
            radius: filter?.radius
        )
        let models = try await local.fetchRecords(request: request)
        return models.map { model in
            RecordMapper.toDomain(model: model)
        }
    }

    /// 순수 Record 단건 조회 (Offline-First)
    public func fetchRecordDetail(
        id: UUID
    ) async throws -> Record {
        if let model = try await local.fetchRecord(id: id) {
            return RecordMapper.toDomain(model: model)
        }
        // 로컬에 없으면 원격에서
        let dto = try await remote.fetchDetail(id: id)
        let model = dto.toModel()
        try await local.save(model: model)
        return RecordMapper.toDomain(model: model)
    }

    /// 공개된 타인 Record들을 조회 (필터: 반경)
    public func fetchPublicRecords(
        in filter: LocationFilter
    ) async throws -> [Record] {
        let request = RecordFetchRequest(
            userId: nil, // 타인 기록이므로 특정 유저 ID 없음
            onlyPublic: true,
            centerLatitude: filter.center.latitude,
            centerLongitude: filter.center.longitude,
            radius: filter.radius
        )
        let models = try await local.fetchPublicRecords(filter: request)
        return models.map { model in
            RecordMapper.toDomain(model: model)
        }
    }

    // MARK: - Write

    /// Record 저장 (신규)
    public func save(
        _ record: Record
    ) async throws {
        let model = RecordModel(
            id: record.id,
            title: record.title,
            latitude: record.coordinate.latitude,
            longitude: record.coordinate.longitude,
            address: record.address.fullAddress,
            date: record.date,
            photoURLs: record.photos.map { $0.url.absoluteString },
            isPublic: record.isPublic,
            authorID: record.authorID,
            markerID: record.markerTypeID
        )

        do {
            try await local.save(model: model)
            print("Record 저장 성공: \(record.id)")
        } catch {
            print("Record 저장 실패: \(record.id), error: \(error)")
            throw error
        }
    }

    /// Record 업데이트
    public func update(
        _ record: Record
    ) async throws {
        let model = RecordModel(
            id: record.id,
            title: record.title,
            latitude: record.coordinate.latitude,
            longitude: record.coordinate.longitude,
            address: record.address.fullAddress,
            date: record.date,
            photoURLs: record.photos.map { $0.url.absoluteString },
            isPublic: record.isPublic,
            authorID: record.authorID,
            markerID: record.markerTypeID
        )
        try await local.save(model: model)
        try await remote.update(model: model)
    }

    /// Record 삭제
    public func delete(
        _ record: Record
    ) async throws {
        try await local.deleteRecordEntity(id: record.id)
        try await remote.delete(id: record.id)
    }
}

public enum RecordRepositoryError: Error {
    case notFound
    case userNotFound
    case markerNotFound
}
