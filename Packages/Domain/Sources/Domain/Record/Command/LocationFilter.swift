//
//  LocationFilter.swift
//  Domain
//
//  Created by eunsong on 7/20/25.
//

import Foundation

/// Record 조회 시 위치 기반 반경 필터
public struct LocationFilter {
    public let center: Coordinate
    public let radius: Double  // 미터 단위

    public init(center: Coordinate, radius: Double) {
        self.center = center
        self.radius = radius
    }
}
