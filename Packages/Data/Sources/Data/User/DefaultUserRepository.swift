import Domain
//
//  DefaultUserRepository.swift
//  Data
//
//  Created by eunsong on 7/15/25.
//
import Foundation

public struct DefaultUserRepository: UserRepository, Sendable {
    private let local: UserLocalDatasource

    public init(
        local: UserLocalDatasource
    ) {
        self.local = local
    }

    public func fetch(by id: UUID) async throws -> User {
        guard let userEntity = try await local.fetchUserEntity() else {
            throw UserDataError.notFound
        }
        return UserMapper.toDomain(entity: userEntity)
    }
    
    public func getOrCreateDefaultUser() async throws -> User {
        let userEntity = try await local.getOrCreateDefaultUser()
        print("[DefaultUserRepository] Returning default user with ID: \(userEntity.id)")
        return UserMapper.toDomain(entity: userEntity)
    }

    public func initializeDefaultUser() async throws {
        _ = try await getOrCreateDefaultUser()
    }
}

enum UserDataError: Error {
    case notFound
}
