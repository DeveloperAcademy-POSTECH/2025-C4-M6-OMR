//
//  User.swift
//  Domain
//
//  Created by eunsong on 7/15/25.
//
import Foundation

public struct User: Equatable, Identifiable, Sendable {
    public let id: UUID

    public init(id: UUID) {
        self.id = id
    }
}
