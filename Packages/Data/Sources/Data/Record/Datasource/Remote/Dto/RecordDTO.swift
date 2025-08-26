import Foundation

/// 원격 API용 RecordDTO 정의
public struct RecordDTO: Codable, Sendable {
    public let id: UUID
//    public let author: UserDTO
//    public let marker: MarkerDTO
    public let title: String?
    public let latitude: Double
    public let longitude: Double
    public let address: String
    public let date: String  // ISO8601
    public let photoURLs: [String]
    public let isPublic: Bool
}
