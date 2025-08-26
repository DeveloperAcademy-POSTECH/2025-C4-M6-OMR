import Foundation
import SwiftData

/// 로컬 SwiftData를 사용한 Record 영속성 계층
public actor LocalRecordDataSource: Sendable {
    private let context: ModelContext
    private let entityMapper: RecordEntityMapper

    public init(container: ModelContainer) {
        self.context = ModelContext(container)
        self.entityMapper = RecordEntityMapper(context: self.context)
        // main actor에서 UI 업데이트를 방해하지 않도록 백그라운드에서 실행
        self.context.autosaveEnabled = true
    }

    // MARK: - Fetch

    /// 단건 RecordEntity 조회
    public func fetchRecord(id: UUID) async throws -> RecordModel? {
        let descriptor = FetchDescriptor<RecordEntity>(
            predicate: #Predicate { $0.id == id }
        )
        guard let entity = try context.fetch(descriptor).first else {
            return nil
        }
        return entity.toModel()
    }

    /// RecordEntity 목록 조회 (필터: 전체 or 반경)
    public func fetchRecords(
        request: RecordFetchRequest?
    ) async throws -> [RecordModel] {
        let descriptor: FetchDescriptor<RecordEntity>
        descriptor = FetchDescriptor(
            predicate: #Predicate { _ in true },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let entities = try context.fetch(descriptor)
        return entities.map { $0.toModel() }
    }

    /// 공개된 타인 RecordEntity 조회 (반경 필터 필수)
    /// (RecordFetchRequest가 아닌 기존 메서드 유지 시)
    public func fetchPublicRecords(
        filter: RecordFetchRequest
    ) async throws -> [RecordModel] {
        // onlyPublic만 true로 설정하고 fetchRecordEntities 호출
        let req = RecordFetchRequest(
            userId: nil,
            onlyPublic: true,
            centerLatitude: filter.centerLatitude,
            centerLongitude: filter.centerLongitude,
            radius: filter.radius
        )
        return try await fetchRecords(request: req)
    }

    // MARK: - CUD

    /// RecordModel 저장 (신규/업데이트)
    public func save(model: RecordModel) async throws {
        do {
            try await entityMapper.save(model: model)
            print("[LocalRecordDataSource] Record saved successfully: \(model.id)")
        } catch {
            print("[LocalRecordDataSource] Failed to save record: \(model.id), error: \(error)")
            throw error
        }
    }

    /// RecordEntity 삭제
    public func deleteRecordEntity(id: UUID) async throws {
        try context.delete(
            model: RecordEntity.self,
            where: #Predicate { $0.id == id }
        )
        try context.save()
    }
}

// MARK: - Helper

/*
private func buildPredicate(from request: RecordFetchRequest) -> Predicate<RecordEntity>? {
    return #Predicate { record in
        var result = true

        if let userId = request.userId {
            result = result && (record.author.id == userId)
        }
        if let onlyPublic = request.onlyPublic {
            result = result && (record.isPublic == onlyPublic)
        }
        if let centerLatitude = request.centerLatitude, let radius = request.radius {
            let minLat = centerLatitude - (radius / 111_000)
            let maxLat = centerLatitude + (radius / 111_000)
            result = result && (record.latitude >= minLat && record.latitude <= maxLat)
            // TODO: 경도 필터링 추가
        }

        return result
    }
}
*/
