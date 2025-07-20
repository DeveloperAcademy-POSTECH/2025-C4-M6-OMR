//
//  RecordFetchRequest.swift
//  Data
//
//  Created by eunsong on 7/21/25.
//

import Foundation

/// 로컬/원격 데이터 계층 전용 “레코드 조회 조건” DTO
public struct RecordFetchRequest: Sendable {
    /// filter by userId if non-nil
    public let userId: UUID?
    /// filter by public flag if non-nil
    public let onlyPublic: Bool?
    /// center latitude for proximity filter if non-nil
    public let centerLatitude: Double?
    /// center longitude for proximity filter if non-nil
    public let centerLongitude: Double?
    /// radius in meters for proximity filter if non-nil
    public let radius: Double?

    public init(
        userId: UUID? = nil,
        onlyPublic: Bool? = nil,
        centerLatitude: Double? = nil,
        centerLongitude: Double? = nil,
        radius: Double? = nil
    ) {
        self.userId = userId
        self.onlyPublic = onlyPublic
        self.centerLatitude = centerLatitude
        self.centerLongitude = centerLongitude
        self.radius = radius
    }
}
