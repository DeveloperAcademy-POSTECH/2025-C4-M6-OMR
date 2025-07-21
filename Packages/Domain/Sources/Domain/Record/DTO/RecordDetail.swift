//
//  RecordDetail.swift
//  Domain
//
//  Created by eunsong on 7/20/25.
//

import Foundation

/// Record + author, marker, like 정보를 묶어 조회용으로 전달하는 DTO
public struct RecordDetail: Sendable {
    public let record: Record
    public let author: User
    public let marker: Marker

    public init(
        record: Record,
        author: User,
        marker: Marker
    ) {
        self.record = record
        self.author = author
        self.marker = marker
    }
}
