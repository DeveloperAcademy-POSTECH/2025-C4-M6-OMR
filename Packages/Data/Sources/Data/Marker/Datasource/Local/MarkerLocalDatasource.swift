//
//  MarkerLocalDatasource.swift
//  Data
//
//  Created by eunsong on 7/21/25.
//

import Foundation
import SwiftData

public struct MarkerLocalDatasource: Sendable {
    let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func fetch(by id: UUID) async throws -> MarkerEntity? {
        // Placeholder implementation
        let descriptor = FetchDescriptor<MarkerEntity>(predicate: #Predicate { $0.id == id })
        return try modelContext.fetch(descriptor).first
    }
}
