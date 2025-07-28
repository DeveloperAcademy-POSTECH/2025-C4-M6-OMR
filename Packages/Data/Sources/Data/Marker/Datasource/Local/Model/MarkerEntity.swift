//
//  MarkerEntity.swift
//  Data
//
//  Created by eunsong on 7/20/25.
//

import Foundation
import SwiftData

@Model
public final class MarkerEntity {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var floriography: String
    public var thumbnailImageName: String
    public var objectImageName: String

    // 단방향: RecordEntity 에서만 MarkerEntity 를 참조
    @Relationship public var records: [RecordEntity]

    public init(
        id: UUID = .init(),
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
        self.records = []
    }
}
