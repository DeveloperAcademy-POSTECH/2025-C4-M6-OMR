import Foundation

/// MoteRepository: Mote 데이터의 영속성을 처리하는 저장소의 인터페이스(프로토콜)
public protocol MoteRepository: Sendable {
    /// 특정 위치 반경 내의 Mote들을 조회합니다.
    /// - Parameters:
    ///   - center: 검색 중심 위치
    ///   - radius: 검색 반경 (미터 단위)
    /// - Returns: 조회된 Mote 배열
    func fetchNearbyMotes(center: Location, radius: Double) async throws
        -> [Mote]

    /// 내 Mote만
    func fetchMyMotes() async throws -> [Mote]

    /// 단건 조회
    func fetchMoteDetail(id: UUID) async throws -> Mote
}
