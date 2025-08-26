//
//  UserEntity.swift
//  Data
//
//  Created by eunsong on 7/20/25.
//
import Foundation
import SwiftData

@Model
public final class UserEntity {
    @Attribute(.unique) public var id: UUID
    public var name: String?
    public var isPublic: Bool

    public init(id: UUID = .init(), name: String? = nil, isPublic: Bool = false) {
        self.id = id
        self.name = name
        self.isPublic = isPublic
    }
}
