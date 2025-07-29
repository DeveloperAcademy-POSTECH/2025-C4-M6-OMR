//
//  DefaultMarkerRepository.swift
//  Data
//
//  Created by eunsong on 7/21/25.
//

import Foundation
import Domain

public struct DefaultMarkerRepository: MarkerRepository, Sendable {
    private let local: MarkerLocalDatasource
    private let defaultDataSource: DefaultMarkerDataSource

    public init(
        local: MarkerLocalDatasource,
        defaultDataSource: DefaultMarkerDataSource
    ) {
        self.local = local
        self.defaultDataSource = defaultDataSource
    }

    public func fetch(by id: UUID) async throws -> Marker {
        guard let entity = try await local.fetch(by: id) else {
            throw MarkerDataError.notFound
        }
        return MarkerMapper.toDomain(entity: entity)
    }
    
    public func fetchAll() async throws -> [Marker] {
        let entities = try await local.fetchAll()
        return entities.map { MarkerMapper.toDomain(entity: $0) }
    }

    public func initializeDefaultMarkers() async throws {
        let existing = try await local.fetchAll()
        guard existing.isEmpty else { return }

        let rawMarkers = defaultDataSource.getRawMarkers()
        let defaultMarkers = rawMarkers
            .map(MarkerMapper.toEntity)

        try await local.saveAll(defaultMarkers)
    }
}

enum MarkerDataError: Error {
    case notFound
}
