import Foundation

public struct ARRecordModel: Identifiable, Equatable, Hashable {
    public let id: UUID
    public let title: String
    public let coordinate: ARCoordinate
    public let modelName: String
    public let createdDate: Date
    public let authorName: String?

    public init(
        id: UUID,
        title: String = "",
        coordinate: ARCoordinate,
        modelName: String,
        createdDate: Date = Date(),
        authorName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.coordinate = coordinate
        self.modelName = modelName
        self.createdDate = createdDate
        self.authorName = authorName
    }

    public static func == (lhs: ARRecordModel, rhs: ARRecordModel) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
