//
//  RemoteMoteDatasource.swift.swift
//  Data
//
//  Created by eunsong on 7/15/25.
//
import Foundation

public actor RemoteRecordDatasource {
    private var storage: [UUID: RecordRemoteDTO]

    public init(initial: [RecordRemoteDTO] = []) {
        self.storage = Dictionary(uniqueKeysWithValues: initial.map { ($0.id, $0) })
    }

    public func fetchDetail(id: UUID) async throws -> RecordRemoteDTO {
        if let dto = storage[id] {
            return dto
        }
        throw NSError(domain: "RemoteRecordDatasource", code: 404)
    }

    public func save(model: RecordModel) async throws {
        let dto = model.toRemoteDTO()
        storage[dto.id] = dto
    }

    public func update(model: RecordModel) async throws {
        let dto = model.toRemoteDTO()
        guard storage[dto.id] != nil else {
            throw NSError(domain: "RemoteRecordDatasource", code: 404)
        }
        storage[dto.id] = dto
    }

    public func delete(id: UUID) async throws {
        storage.removeValue(forKey: id)
    }
}
