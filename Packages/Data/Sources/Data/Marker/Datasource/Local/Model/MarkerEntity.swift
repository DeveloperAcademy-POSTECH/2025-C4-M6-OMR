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
    public var displayName: String
    public var floriography: String
    public var imageName: String

    // 단방향: RecordEntity 에서만 MarkerEntity 를 참조
    @Relationship public var records: [RecordEntity]

    public init(
        id: UUID = .init(),
        displayName: String,
        floriography: String,
        imageName: String
    ) {
        self.id = id
        self.displayName = displayName
        self.floriography = floriography
        self.imageName = imageName
        self.records = []
    }
}
