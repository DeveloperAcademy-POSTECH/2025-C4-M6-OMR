
import Foundation

// 선택 가능한 꽃 데이터 모델
public struct ARFlower: Identifiable, Equatable, Hashable {
    public let id: UUID
    public let name: String
    public let modelName: String // realitykit에 사용할 모델 파일 이름
    public let floriography: String? // 꽃말 추가
    
    public init(
        id: UUID = UUID(),
        name: String,
        modelName: String,
        floriography: String? = nil
    ) {
        self.id = id
        self.name = name
        self.modelName = modelName
        self.floriography = floriography
    }
    
    public static func == (lhs: ARFlower, rhs: ARFlower) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
