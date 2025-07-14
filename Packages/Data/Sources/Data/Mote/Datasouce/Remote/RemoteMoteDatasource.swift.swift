//
//  RemoteMoteDatasource.swift.swift
//  Data
//
//  Created by eunsong on 7/15/25.
//
import Domain
import Foundation

public struct RemoteMoteDatasource: Sendable {
    
    public init() {
    }
    
    func fetchNearbyMotes(center: Location, radius: Double) async throws -> [MoteDTO] {
        return []
    }

    func fetchMoteDetail(id: UUID) async throws -> MoteDTO {
        throw URLError(.badURL)
    }
}
