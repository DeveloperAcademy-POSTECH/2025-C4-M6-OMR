//
//  Photo.swift
//  Domain
//
//  Created by eunsong on 7/20/25.
//
import Foundation

public struct Photo: Equatable, Sendable {
    public let url: URL

    public init(url: URL) {
        self.url = url
    }
}
