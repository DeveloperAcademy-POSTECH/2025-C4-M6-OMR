//
//  RecordRemoteDTO.swift
//  Data
//
//  Created by eunsong on 7/21/25.
//

import Foundation

public struct RecordRemoteDTO: Codable, Sendable, Equatable {
    public let id: UUID
    public let title: String?
    public let latitude: Double
    public let longitude: Double
    public let address: String
    public let date: Date
    public let imageURLs: [String]
    public let isPublic: Bool
    public let authorID: UUID
    public let markerID: UUID
}

extension RecordRemoteDTO {
    func toModel() -> RecordModel {
        return RecordModel(
            id: self.id,
            title: self.title,
            latitude: self.latitude,
            longitude: self.longitude,
            address: self.address,
            date: self.date,
            photoURLs: self.imageURLs,
            isPublic: self.isPublic,
            authorID: self.authorID,
            markerID: self.markerID
        )
    }
}
