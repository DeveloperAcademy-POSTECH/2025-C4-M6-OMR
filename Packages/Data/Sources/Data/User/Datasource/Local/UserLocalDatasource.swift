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
}
