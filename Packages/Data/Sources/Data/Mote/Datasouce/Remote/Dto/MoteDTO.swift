import Foundation

/// MoteDTO: 원격 API와 통신하기 위한 데이터 전송 객체 (Data Transfer Object)
public struct MoteDTO: Codable, Sendable {
    public let id: UUID
    public let title: String
    public let content: String
    public let createdAt: Date
    public let latitude: Double
    public let longitude: Double
    public let address: String
    public let albumCoverURL: URL?
    public let authorId: UUID
    public let likeCount: Int
    public let isLiked: Bool   // ← Domain 의 hasLiked 와 매핑
}
