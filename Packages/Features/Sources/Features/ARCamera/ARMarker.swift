
import RealityKit
import Combine
import DesignSystem
import Foundation

/// AR 공간에 표시되는 개별 레코드를 나타내는 Entity입니다.
class ARMarker: Entity, HasCollision {

    let record: ARRecordModel
    private var cancellables = Set<AnyCancellable>()

    init(record: ARRecordModel) {
        self.record = record
        super.init()

        self.generateCollisionShapes(recursive: true)
        
        cancellables.insert(
            ModelEntity.loadModelAsync(named: record.modelName)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        let fallbackModel = ModelComponent(
                            mesh: .generateSphere(radius: 0.15),
                            materials: [SimpleMaterial(color: .blue, isMetallic: false)]
                        )
                        self?.components.set(fallbackModel)
                    }
                }, receiveValue: { [weak self] modelEntity in
                    if let modelComponent = modelEntity.components[ModelComponent.self] {
                        self?.components.set(modelComponent)
                    }
                })
        )
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}



