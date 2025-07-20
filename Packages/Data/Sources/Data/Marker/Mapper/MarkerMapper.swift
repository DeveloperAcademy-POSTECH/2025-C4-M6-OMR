//
//  MarkerMapper.swift
//  Data
//
//  Created by eunsong on 7/20/25.
//

import Foundation
import Domain

enum MarkerMapper {
    static func toEntity(domain: Marker) -> MarkerEntity {
        .init(
            id: domain.id,
            name: domain.name,
            floriography: domain.floriography,
            emotionTypeRaw: domain.emotionType.rawValue,
            thumbnailImageName: domain.thumbnailImageName,
            objectImageName: domain.objectImageName
        )
    }

    static func toDomain(entity: MarkerEntity) -> Marker {
        .init(
            id: entity.id,
            name: entity.name,
            floriography: entity.floriography,
            emotionType: EmotionType(rawValue: entity.emotionTypeRaw) ?? .all,
            thumbnailImageName: entity.thumbnailImageName,
            objectImageName: entity.objectImageName
        )
    }
}
