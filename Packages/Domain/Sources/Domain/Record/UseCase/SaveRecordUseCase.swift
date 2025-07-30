//
//  SaveRecordUseCase.swift
//  Domain
//
//  Created by eunsong on 7/20/25.
//
import Dependencies
import Foundation
import OSLog

public struct SaveRecordUseCase: Sendable {
    @Dependency(\.recordRepository) private var recordRepository
    @Dependency(\.userRepository) private var userRepository

    public init() { }

    public func callAsFunction(_ record: Record) async throws {
        do {
            let user = try await userRepository.getOrCreateDefaultUser()
            let updatedRecord = record.with(authorID: user.id)
            try await recordRepository.save(updatedRecord)
            print("[SaveRecordUseCase] Record saved successfully: \(record.id)")
        } catch {
            print("[SaveRecordUseCase] Save failed: \(error)")
            throw error
        }
    }
}
