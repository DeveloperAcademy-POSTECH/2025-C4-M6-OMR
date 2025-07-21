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

    public init(
        local: MarkerLocalDatasource
    ) {
        self.local = local
    }

    public func fetch(by id: UUID) async throws -> Marker {
        // Placeholder implementation
        throw MarkerDataError.notFound
    }
}

enum MarkerDataError: Error {
    case notFound
}
