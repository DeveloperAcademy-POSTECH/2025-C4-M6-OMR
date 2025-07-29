//
//  UserLocalDatasource.swift
//  Data
//
//  Created by eunsong on 7/15/25.
//

import Foundation
import SwiftData

public struct UserLocalDatasource: Sendable {
    let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// 로컬 저장소에서 UserEntity를 조회
    public func fetchUserEntity() async throws -> UserEntity? {
        let entities: [UserEntity] = try await modelContext.fetch(
            FetchDescriptor<UserEntity>()
        )
        return entities.first
    }

    /// UserEntity를 로컬에 저장
    public func save(entity: UserEntity) async throws {
        try await modelContext.insert(entity)
        try await modelContext.save()
    }

    /// 기본 유저가 없으면 생성 후 반환
    public func getOrCreateDefaultUser() async throws -> UserEntity {
        if let existing = try await fetchUserEntity() {
            print("[UserLocalDatasource] Found existing user: \(existing.id)")
            return existing
        }

        let defaultUser = UserEntity(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            name: "Default User"
        )

        try await save(entity: defaultUser)
        print("[UserLocalDatasource] Created default user with id: \(defaultUser.id)")
        return defaultUser
    }
}
