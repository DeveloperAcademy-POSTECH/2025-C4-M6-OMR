//
//  DefaultMoteRepository.swift
//  Data
//
//  Created by eunsong on 7/15/25.
//

import Domain
import Foundation

/// 기본 MoteRepository 구현체
public struct DefaultMoteRepository: MoteRepository, Sendable {
    private let local: LocalMoteDatasource
    private let remote: RemoteMoteDatasource
    private let currentUserProvider: @Sendable () async throws -> UUID

    public init(
        local: LocalMoteDatasource,
        remote: RemoteMoteDatasource,
        currentUserProvider: @escaping @Sendable () async throws -> UUID
    ) {
        self.local = local
        self.remote = remote
        self.currentUserProvider = currentUserProvider
    }

    /// 지정된 위치 반경 내의 모든 Mote를 원격에서 가져오고, 로컬에도 저장 후 반환합니다.
    public func fetchNearbyMotes(center: Location, radius: Double) async throws
        -> [Mote]
    {
        return []
    }

    /// 내 Mote만 로컬에서 불러옵니다.
    public func fetchMyMotes() async throws -> [Mote] {
        let myId = try await currentUserProvider()  // 현재 유저 ID 확보
        let entities = try await local.fetchMyMoteEntities(currentUserId: myId)
        return entities.map(MoteMapper.toDomain(entity:))
    }

    /// 단일 Mote를 먼저 로컬에서 찾고, 없으면 원격에서 가져와 로컬에 저장 후 반환합니다.
    public func fetchMoteDetail(id: UUID) async throws -> Mote {
        // 1) 로컬 조회
        if let entity = try await local.fetchMoteEntity(id: id) {
            return MoteMapper.toDomain(entity: entity)
        }
        // 2) 원격 API 호출
        let dto = try await remote.fetchMoteDetail(id: id)
        let mote = MoteMapper.toDomain(dto: dto)
        // 3) 로컬 저장
        let entity = MoteMapper.toEntity(domain: mote)
        try await local.save(entity: entity)
        return mote
    }
}
