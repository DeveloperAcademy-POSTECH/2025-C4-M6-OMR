//
//  RecordMapper.swift
//  Data
//
//  Created by eunsong on 7/21/25.
//

import Foundation
import Domain

enum RecordMapper {
    static func toDomain(model: RecordModel) -> Record {
        return Record(
            id: model.id,
            authorID: model.authorID,
            markerTypeID: model.markerID,
            title: model.title,
            coordinate: Coordinate(latitude: model.latitude, longitude: model.longitude),
            address: Address(fullAddress: model.address),
            date: model.date,
            photos: model.photoURLs.compactMap { URL(string: $0) }.map { Photo(url: $0) },
            isPublic: model.isPublic
        )
    }

    static func toModel(domain: Record) -> RecordModel {
        return RecordModel(
            id: domain.id,
            title: domain.title,
            latitude: domain.coordinate.latitude,
            longitude: domain.coordinate.longitude,
            address: domain.address.fullAddress,
            date: domain.date,
            photoURLs: domain.photos.map { $0.url.absoluteString },
            isPublic: domain.isPublic,
            authorID: domain.authorID,
            markerID: domain.markerTypeID
        )
    }
}
