//
//  MoteEntity.swift
//  Data
//
//  Created by eunsong on 7/15/25.
//
import Foundation
import SwiftData

@Model
public final class MoteEntity {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var content: String
    public var createdAt: Date
    public var latitude: Double
    public var longitude: Double
    public var address: String
    public var albumCoverURL: URL?
    public var likeCount: Int
    public var isLiked: Bool

    // 작성자 참조
    @Relationship(deleteRule: .nullify) public var author: UserEntity?

    public init(
        id: UUID,
        title: String,
        content: String,
        createdAt: Date,
        latitude: Double,
        longitude: Double,
        address: String,
        albumCoverURL: URL?,
        likeCount: Int,
        isLiked: Bool,
        author: UserEntity? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.albumCoverURL = albumCoverURL
        self.likeCount = likeCount
        self.isLiked = isLiked
        self.author = author
    }
}
