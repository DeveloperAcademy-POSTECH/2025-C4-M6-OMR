//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/18/25.
//
import Foundation


// MARK: - Emotion Type

public enum EmotionType: String {
    case happiness, sadness, love, anger, fear
}

// MARK: - Flower Object

public final class EmotionObject {
    public var id: UUID
    public var name: String
    public var floriography: String
    public var emotionType: EmotionType
    public var thumbnail: String
    public var objetImage: String

    public init(id: UUID = UUID(),
                name: String,
                floriography: String,
                emotionType: EmotionType,
                thumbnail: String,
                objetImage: String) {
        self.id = id
        self.name = name
        self.floriography = floriography
        self.emotionType = emotionType
        self.thumbnail = thumbnail
        self.objetImage = objetImage
    }
}

// MARK: - Mote Object

public final class Mote {
    public var id: UUID
    public var userId: UUID
    public var title: String
    public var images: [String]
    public var createdAt: Date
    public var latitude: Double
    public var longitude: Double
    public var address: String
    public var flower: EmotionObject
    public var isPublic: Bool

    public init(id: UUID = UUID(),
                userId: UUID,
                title: String,
                images: [String],
                createdAt: Date,
                latitude: Double,
                longitude: Double,
                address: String,
                flower: EmotionObject,
                isPublic: Bool) {
        self.id = id
        self.userId = userId
        self.title = title
        self.images = images
        self.createdAt = createdAt
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.flower = flower
        self.isPublic = isPublic
    }
}

