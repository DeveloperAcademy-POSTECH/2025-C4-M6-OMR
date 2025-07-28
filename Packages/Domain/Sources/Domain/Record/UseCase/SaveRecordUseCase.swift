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
    @Dependency(\.recordRepository) private var recordRepo
    @Dependency(\.userRepository) private var userRepo
    private let logger = Logger(
        subsystem: "com.mote.Domain",
        category: "SaveRecordUseCase"
    )

    public init() {}

    public func callAsFunction(_ record: Record) async throws {
        do {
            let user = try await userRepo.getOrCreateDefaultUser()
            let updatedRecord = record.with(authorID: user.id)
            try await recordRepo.save(updatedRecord)
        } catch {
            logger.error("Failed to save record: \(error.localizedDescription)")
            throw error
        }
    }
}
