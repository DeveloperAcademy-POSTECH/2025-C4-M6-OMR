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
}

enum UserDataError: Error {
    case notFound
}
