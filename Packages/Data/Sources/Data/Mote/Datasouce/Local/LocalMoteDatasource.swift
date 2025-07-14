//
//  LocalMoteDatasource.swift
//  Data
//
//  Created by eunsong on 7/15/25.
//

import Foundation
import SwiftData
import FileProvider
import Domain

public struct LocalMoteDatasource: Sendable {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// 내 Mote 엔티티만 조회 (author.id == currentUserId)
    public func fetchMyMoteEntities(currentUserId: UUID) async throws -> [MoteEntity] {
        let all: [MoteEntity] = try await modelContext.fetch(FetchDescriptor<MoteEntity>())
        return all.filter { $0.author?.id == currentUserId }
    }

    /// 반경 내 모든 MoteEntity 조회
    public func fetchNearbyMoteEntities(center: Location, radius: Double) async throws -> [MoteEntity] {
        // 모든 MoteEntity를 불러온 뒤 단순 거리 계산으로 필터링
        let all: [MoteEntity] = try await modelContext.fetch(FetchDescriptor<MoteEntity>())
        return all.filter {
            let latDiff = $0.latitude - center.latitude
            let lonDiff = $0.longitude - center.longitude
            return sqrt(latDiff * latDiff + lonDiff * lonDiff) <= radius
        }
    }

    /// 단일 MoteEntity 조회
    public func fetchMoteEntity(id: UUID) async throws -> MoteEntity? {
        let descriptor = FetchDescriptor<MoteEntity>(
            predicate: #Predicate<MoteEntity> { $0.id == id }
        )
        let results: [MoteEntity] = try await modelContext.fetch(descriptor)
        return results.first
    }

    /// MoteEntity 배열 저장 (삽입 및 커밋)
    public func save(entities: [MoteEntity]) async throws {
        for e in entities {
            try await modelContext.insert(e)
        }
        try await modelContext.save()
    }

    /// 단일 MoteEntity 저장
    public func save(entity: MoteEntity) async throws {
        try await modelContext.insert(entity)
        try await modelContext.save()
    }
}
