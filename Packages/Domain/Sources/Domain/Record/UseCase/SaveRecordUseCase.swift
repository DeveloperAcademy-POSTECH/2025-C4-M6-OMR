//
//  SaveRecordUseCase.swift
//  Domain
//
//  Created by eunsong on 7/20/25.
//
import Dependencies
import Foundation

public struct SaveRecordUseCase: Sendable {
    @Dependency(\.recordRepository) private var repo

    public init() {}

    public func callAsFunction(_ record: Record) async throws {
        try await repo.save(record)
    }
}
