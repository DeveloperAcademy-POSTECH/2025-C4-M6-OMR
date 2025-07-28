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
            thumbnailImageName: domain.thumbnailImageName,
            objectImageName: domain.objectImageName
        )
    }
    
    static func toEntity(defaultData: RawMarkerData) -> MarkerEntity {
        .init(
            id: defaultData.id,
            name: defaultData.name,
            floriography: defaultData.floriography,
            thumbnailImageName: defaultData.thumbnailImageName,
            objectImageName: defaultData.objectImageName
        )
    }

    static func toDomain(entity: MarkerEntity) -> Marker {
        .init(
            id: entity.id,
            name: entity.name,
            floriography: entity.floriography,
            thumbnailImageName: entity.thumbnailImageName,
            objectImageName: entity.objectImageName
        )
    }
}
