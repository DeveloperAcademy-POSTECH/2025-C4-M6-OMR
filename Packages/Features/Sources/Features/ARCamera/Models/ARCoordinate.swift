//
//  ARCoordinate.swift
//  Features
//
//  Created by eunsong on 7/26/25.
//
import simd

public struct ARCoordinate: Equatable, Hashable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    // 거리 계산 편의 메서드
    public func distance(from other: ARCoordinate) -> Double {
        let earthRadius: Double = 6_371_000  // 지구 반지름 (미터)

        let lat1Rad = latitude * .pi / 180
        let lat2Rad = other.latitude * .pi / 180
        let deltaLatRad = (other.latitude - latitude) * .pi / 180
        let deltaLonRad = (other.longitude - longitude) * .pi / 180

        let a =
            sin(deltaLatRad / 2) * sin(deltaLatRad / 2) + cos(lat1Rad)
            * cos(lat2Rad) * sin(deltaLonRad / 2) * sin(deltaLonRad / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return earthRadius * c
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}
