
//
//  RecordEntityMapper.swift
//  Data
//
//  Created by eunsong on 7/21/25.
//

import Foundation
import SwiftData

public actor RecordEntityMapper {
    private let context: ModelContext

    public init(context: ModelContext) {
        self.context = context
    }

    func save(model: RecordModel) async throws {
        let userEntity = try await fetchUserEntity(id: model.authorID)
        let markerEntity = try await fetchMarkerEntity(id: model.markerID)

        let encoder = JSONEncoder()
        let photoURLsString = String(data: try encoder.encode(model.photoURLs), encoding: .utf8) ?? "[]"

        if let existing = try await fetchRecordEntity(id: model.id) {
            // Update existing entity
            existing.title = model.title
            existing.latitude = model.latitude
            existing.longitude = model.longitude
            existing.address = model.address
            existing.date = model.date
            existing.photoURLs = photoURLsString
            existing.isPublic = model.isPublic
            existing.author = userEntity
            existing.marker = markerEntity
        } else {
            // Insert new entity
            let newEntity = RecordEntity(
                id: model.id,
                author: userEntity,
                marker: markerEntity,
                title: model.title,
                latitude: model.latitude,
                longitude: model.longitude,
                address: model.address,
                date: model.date,
                photoURLs: photoURLsString,
                isPublic: model.isPublic
            )
            context.insert(newEntity)
        }
        try context.save()
    }

    // MARK: - Private Helpers

    private func fetchRecordEntity(id: UUID) async throws -> RecordEntity? {
        let descriptor = FetchDescriptor<RecordEntity>(predicate: #Predicate { $0.id == id })
        return try context.fetch(descriptor).first
    }

    private func fetchUserEntity(id: UUID) async throws -> UserEntity {
        let descriptor = FetchDescriptor<UserEntity>(predicate: #Predicate { $0.id == id })
        guard let user = try context.fetch(descriptor).first else {
            throw RecordDataError.userNotFound
        }
        return user
    }

    private func fetchMarkerEntity(id: UUID) async throws -> MarkerEntity {
        let descriptor = FetchDescriptor<MarkerEntity>(predicate: #Predicate { $0.id == id })
        guard let marker = try context.fetch(descriptor).first else {
            throw RecordDataError.markerNotFound
        }
        return marker
    }
}

public enum RecordDataError: Error {
    case notFound
    case userNotFound
    case markerNotFound
}
