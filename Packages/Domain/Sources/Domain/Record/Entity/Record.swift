import Foundation

/// Mote: 사용자가 기록한 위치 기반의 음악 기록 엔티티
public struct Record: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let authorID: UUID
    public let markerTypeID: UUID
    public var title: String?
    public let coordinate: Coordinate
    public let address: Address
    public let date: Date
    public var photos: [Photo]
    public var isPublic: Bool

    public init(
        id: UUID,
        authorID: UUID,
        markerTypeID: UUID,
        title: String? = nil,
        coordinate: Coordinate,
        address: Address,
        date: Date,
        photos: [Photo],
        isPublic: Bool = false
    ) {
        self.id = id
        self.authorID = authorID
        self.markerTypeID = markerTypeID
        self.title = title
        self.coordinate = coordinate
        self.address = address
        self.date = date
        self.photos = photos
        self.isPublic = isPublic
    }
}
