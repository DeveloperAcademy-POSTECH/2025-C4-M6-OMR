//
//  UserMapper.swift
//  Data
//
//  Created by eunsong on 7/20/25.
//

import Foundation
import Domain

enum UserMapper {
    static func toEntity(domain: User) -> UserEntity {
        .init(
            id: domain.id,
            name: domain.name,
            isPublic: domain.isPublic
        )
    }

    static func toDomain(entity: UserEntity) -> User {
        .init(
            id: entity.id,
            name: entity.name,
            isPublic: entity.isPublic
        )
    }
}
