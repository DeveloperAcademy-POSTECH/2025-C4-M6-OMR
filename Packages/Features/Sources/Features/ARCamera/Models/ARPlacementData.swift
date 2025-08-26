//
//  ARPlacementData.swift
//  Features
//
//  Created by eunsong on 7/26/25.
//
import Foundation

// MARK: - ARPlacementData (새로운 배치 상태 모델)
public struct ARPlacementData: Equatable {
    public let flower: ARFlower
    public let position: ARCoordinate
    public let isConfirmed: Bool
    public let placedAt: Date

    public init(
        flower: ARFlower,
        position: ARCoordinate,
        isConfirmed: Bool = false,
        placedAt: Date = Date()
    ) {
        self.flower = flower
        self.position = position
        self.isConfirmed = isConfirmed
        self.placedAt = placedAt
    }
}
