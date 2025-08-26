//
//  User.swift
//  Domain
//
//  Created by eunsong on 7/15/25.
//
import Foundation

public struct User: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let name: String?
    public let isPublic: Bool    // 전체 공개 여부

    public init(id: UUID, name: String? = "", isPublic: Bool = false) {
        self.id = id
        self.name = name
        self.isPublic = isPublic
    }
}
