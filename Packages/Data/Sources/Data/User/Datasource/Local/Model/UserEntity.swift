//
//  UserEntity.swift
//  Data
//
//  Created by eunsong on 7/15/25.
//
import Foundation
import SwiftData

@Model
public final class UserEntity {
    @Attribute(.unique) public var id: UUID
    
    // 역관계: 이 유저가 작성한 Mote들
    @Relationship(deleteRule: .cascade, inverse: \MoteEntity.author)
    public var motes: [MoteEntity]
    
    public init(id: UUID, motes: [MoteEntity] = []) {
        self.id = id
        self.motes = motes
    }
}
