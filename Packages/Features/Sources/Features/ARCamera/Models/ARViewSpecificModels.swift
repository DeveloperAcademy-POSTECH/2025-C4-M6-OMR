//
//  ARViewSpecificModels.swift
//
//
//  Created by Eunsong on 2025/07/24.
//

import Foundation

public struct Coordinate: Equatable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public enum MarkerType: Equatable {
    case flower(type: FlowerType)
    case rock

    public enum FlowerType: String, Equatable {
        case flower1
        case flower2
    }
}
