import Foundation

/// Mote: 사용자가 기록한 위치 기반의 음악 기록 엔티티
public struct Mote: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let content: String
    public let createdAt: Date
    public let location: Location
    public let address: String
    public let albumCoverURL: URL?
    public let author: User
    public let likeCount: Int
    public let hasLiked: Bool  // 내가 좋아요 눌렀는지

    public init(
        id: UUID,
        title: String,
        content: String,
        createdAt: Date,
        location: Location,
        address: String,
        albumCoverURL: URL?,
        author: User,
        likeCount: Int,
        hasLiked: Bool
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.location = location
        self.address = address
        self.albumCoverURL = albumCoverURL
        self.author = author
        self.likeCount = likeCount
        self.hasLiked = hasLiked
    }
}
