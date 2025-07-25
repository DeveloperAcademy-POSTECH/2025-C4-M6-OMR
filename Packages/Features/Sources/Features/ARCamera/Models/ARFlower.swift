
import Foundation

// 선택 가능한 꽃 데이터 모델
public struct ARFlower: Identifiable, Equatable {
    public let id: UUID
    public let name: String
    public let modelName: String // RealityKit에서 사용할 모델 파일 이름
    
    public init(id: UUID = UUID(), name: String, modelName: String) {
        self.id = id
        self.name = name
        self.modelName = modelName
    }
    
    public static func == (lhs: ARFlower, rhs: ARFlower) -> Bool {
        lhs.id == rhs.id
    }
}

