//
//  Marker.swift
//  Domain
//
//  Created by eunsong on 7/20/25.
//
import Foundation

public struct Marker: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let displayName: String
    public let floriography: String
    public let imageName: String
    
    public var smallThumbnailImageName: String {
        "\(imageName)_S"
    }

    public var largeThumbnailImageName: String {
        "\(imageName)_L"
    }
    
    public init(
        id: UUID,
        displayName: String,
        floriography: String,
        imageName: String
    ) {
        self.id = id
        self.displayName = displayName
        self.floriography = floriography
        self.imageName = imageName
    }
}
