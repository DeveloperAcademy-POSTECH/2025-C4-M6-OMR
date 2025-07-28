//
//  UserRepository.swift
//  Domain
//
//  Created by eunsong on 7/15/25.
//

import Foundation

public protocol UserRepository: Sendable {
    func fetch(by id: UUID) async throws -> User
    func getOrCreateDefaultUser() async throws -> User
}
