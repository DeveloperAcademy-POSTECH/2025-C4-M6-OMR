//
//  RecordEntity.swift
//  Data
//
//  Created by eunsong on 7/20/25.
//

import Foundation
import SwiftData

@Model
public final class RecordEntity {
    @Attribute(.unique) public var id: UUID

    // 단방향: RecordEntity 에서만 UserEntity, MarkerEntity 를 참조
    @Relationship public var author: UserEntity
    @Relationship public var marker: MarkerEntity

    public var title: String?
    public var latitude: Double
    public var longitude: Double
    public var address: String
    public var date: Date
    public var photoURLs: String  // JSON-encoded [String]
    public var isPublic: Bool

    public init(
        id: UUID = .init(),
        author: UserEntity,
        marker: MarkerEntity,
        title: String? = nil,
        latitude: Double,
        longitude: Double,
        address: String,
        date: Date = .init(),
        photoURLs: String = "[]",
        isPublic: Bool = false
    ) {
        self.id = id
        self.author = author
        self.marker = marker
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.date = date
        self.photoURLs = photoURLs
        self.isPublic = isPublic
    }
}

extension RecordEntity {
    func toModel() -> RecordModel {
        let decoder = JSONDecoder()
        let decodedPhotoURLs = (try? decoder.decode([String].self, from: self.photoURLs.data(using: .utf8)!)) ?? []

        return RecordModel(
            id: self.id,
            title: self.title,
            latitude: self.latitude,
            longitude: self.longitude,
            address: self.address,
            date: self.date,
            photoURLs: decodedPhotoURLs,
            isPublic: self.isPublic,
            authorID: self.author.id,
            markerID: self.marker.id
        )
    }
}
