import Foundation

/// AR카메라 View에서 사용하기 위한 레코드 모델
public struct ARRecordModel: Identifiable, Equatable {
    public let id: UUID
    public let title: String
    public let coordinate: ARCoordinate
    
    /// 3D 모델 파일 이름 (View를 위한 정보)
    public let modelName: String
    
    public init(id: UUID, title: String = "", coordinate: ARCoordinate, modelName: String) {
        self.id = id
        self.title = title
        self.coordinate = coordinate
        self.modelName = modelName
    }
}

public struct ARCoordinate: Equatable {
    public let latitude: Double
    public let longitude: Double
}
