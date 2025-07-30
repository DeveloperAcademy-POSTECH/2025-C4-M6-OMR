//
//  RecordDetailMapper.swift
//  Features
//
//  Created by eunsong on 7/30/25.
//

import Domain
import Foundation

struct RecordDetailMapper {
    static func toMote(from detail: RecordDetail) -> Mote {
        return Mote(
            id: detail.record.id,
            userId: detail.author.id,
            title: detail.record.title ?? "",
            images: detail.record.photos.map { $0.url.absoluteString },
            createdAt: detail.record.date,
            latitude: detail.record.coordinate.latitude,
            longitude: detail.record.coordinate.longitude,
            address: detail.record.address.fullAddress,
            flower: EmotionObject(
                id: detail.marker.id,
                name: detail.marker.displayName,
                floriography: detail.marker.floriography,
                thumbnail: detail.marker.smallThumbnailImageName,
                objetImage: detail.marker.largeThumbnailImageName
            ),
            isPublic: detail.record.isPublic
        )
    }
}
