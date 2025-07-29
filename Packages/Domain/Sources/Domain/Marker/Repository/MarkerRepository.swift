//
//  MarkerRepository.swift
//  Domain
//
//  Created by eunsong on 7/21/25.
//
import Foundation

public protocol MarkerRepository: Sendable {
    func fetch(by id: UUID) async throws -> Marker
    func initializeDefaultMarkers() async throws
    func fetchAll() async throws -> [Marker]
}
