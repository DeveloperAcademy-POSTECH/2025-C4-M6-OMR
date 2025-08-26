//
//  Address.swift
//  Domain
//
//  Created by eunsong on 7/20/25.
//

public struct Address: Equatable, Sendable {
    public let fullAddress: String

    public init(fullAddress: String) {
        self.fullAddress = fullAddress
    }
}
