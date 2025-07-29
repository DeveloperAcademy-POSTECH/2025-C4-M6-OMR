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
            displayName: domain.displayName,
            floriography: domain.floriography,
            imageName: domain.imageName
        )
    }

    static func toEntity(defaultData: RawMarkerData) -> MarkerEntity {
        .init(
            id: defaultData.id,
            displayName: defaultData.displayName,
            floriography: defaultData.floriography,
            imageName: defaultData.imageName
        )
    }

    static func toDomain(entity: MarkerEntity) -> Marker {
        .init(
            id: entity.id,
            displayName: entity.displayName,
            floriography: entity.floriography,
            imageName: entity.imageName
        )
    }
}
