//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/23/25.
//

import Foundation

public final class FlowerModel {
    public let id: UUID
    public let name: String
    public let floriography: String
    public let thumbnailImageName: String
    public let objectImageName: String
    public let thumbnailLarge: String
    
    public init(id: UUID = UUID(),
                name: String,
                floriography: String,
                thumbnailImageName: String,
                objectImageName: String,
                thumbnailLarge: String
    ) {
        self.id = id
        self.name = name
        self.floriography = floriography
        self.thumbnailImageName = thumbnailImageName
        self.objectImageName = objectImageName
        self.thumbnailLarge = thumbnailLarge
    }
}
