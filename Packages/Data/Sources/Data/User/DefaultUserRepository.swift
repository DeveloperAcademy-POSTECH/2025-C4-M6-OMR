//
//  DefaultUserRepository.swift
//  Data
//
//  Created by eunsong on 7/15/25.
//
import Foundation
import Domain

public struct DefaultUserRepository: UserRepository, Sendable {
    private let local: UserLocalDatasource

    public init(
        local: UserLocalDatasource
    ) {
        self.local = local
    }
}
