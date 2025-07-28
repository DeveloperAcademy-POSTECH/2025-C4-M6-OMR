//
//  Marker.swift
//  Domain
//
//  Created by eunsong on 7/20/25.
//
import Foundation

public struct Marker: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let floriography: String
    public let thumbnailImageName: String
    public let objectImageName: String
    
    public init(
        id: UUID,
        name: String,
        floriography: String,
        thumbnailImageName: String,
        objectImageName: String
    ) {
        self.id = id
        self.name = name
        self.floriography = floriography
        self.thumbnailImageName = thumbnailImageName
        self.objectImageName = objectImageName
    }
}
