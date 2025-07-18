//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/18/25.
//

import Foundation
import CoreLocation

public final class MainMote {
    public var id: UUID
    public var latitude: Double
    public var longitude: Double

    public init(id: UUID = UUID(),
                latitude: Double,
                longitude: Double) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
    }
}
