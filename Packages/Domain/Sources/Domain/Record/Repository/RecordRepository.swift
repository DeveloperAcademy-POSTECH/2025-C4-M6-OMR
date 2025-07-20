import Foundation

/// Record 도메인의 영속성을 담당하는 저장소 인터페이스
public protocol RecordRepository: Sendable {
    // MARK: - Read

    /// 내 기록을 조회합니다.
    ///
    /// - Parameter filter:
    ///   - `nil` 이면 **모든 내 기록** 을,
    ///   - non-nil 이면 해당 위치 반경 내의 내 기록만 조회합니다.
    /// - Returns: 조회된 RecordDetail 배열
    func fetchMyRecords(
        in filter: LocationFilter?
    ) async throws -> [Record]

    /// 단건 Record 상세 조회
    ///
    /// - Parameter id: 조회할 Record의 고유 ID
    /// - Returns: 조회된 RecordDetail
    func fetchRecordDetail(
        id: UUID
    ) async throws -> Record

    /// 반경 내 **공개된 다른 사람** Record들만 조회합니다.
    ///
    /// - Parameter filter: 위치 필터 (center + radius)
    /// - Returns: 조회된 RecordDetail 배열
    func fetchPublicRecords(
        in filter: LocationFilter
    ) async throws -> [Record]

    // MARK: - Write

    /// 기록 저장 (신규)
    func save(
        _ record: Record
    ) async throws

    /// 기록 업데이트 (수정)
    func update(
        _ record: Record
    ) async throws

    /// 기록 삭제
    func delete(
        _ record: Record
    ) async throws
}
