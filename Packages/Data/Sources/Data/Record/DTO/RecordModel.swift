//
//  RecordModel.swift
//  Data
//
//  Created by eunsong on 7/21/25.
//

import Foundation

public struct RecordModel: Codable, Sendable, Equatable {
    public let id: UUID
    public let title: String?
    public let latitude: Double
    public let longitude: Double
    public let address: String
    public let date: Date
    public let photoURLs: [String]
    public let isPublic: Bool
    public let authorID: UUID
    public let markerID: UUID
}

extension RecordModel {
    func toRemoteDTO() -> RecordRemoteDTO {
        return RecordRemoteDTO(
            id: self.id,
            title: self.title,
            latitude: self.latitude,
            longitude: self.longitude,
            address: self.address,
            date: self.date,
            imageURLs: self.photoURLs,
            isPublic: self.isPublic,
            authorID: self.authorID,
            markerID: self.markerID
        )
    }
}