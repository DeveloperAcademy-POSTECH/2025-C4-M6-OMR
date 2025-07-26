import Combine
import DesignSystem
import Foundation
import RealityKit

class ARMarker: Entity, HasCollision {
    let record: ARRecordModel
    private var cancellables = Set<AnyCancellable>()
    
    init(record: ARRecordModel) {
        self.record = record
        super.init()
        
        loadModel()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    private func loadModel() {
        ModelEntity.loadModelAsync(named: record.modelName)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.setupFallbackModel()
                    }
                },
                receiveValue: { [weak self] modelEntity in
                    guard let self = self else { return }
                    // Add the loaded model as a child to preserve its hierarchy
                    // and ensure collision shapes are generated correctly.
                    self.addChild(modelEntity)
                    self.generateCollisionShapes(recursive: true)
                }
            )
            .store(in: &cancellables)
    }
    
    private func setupFallbackModel() {
        let fallbackModel = ModelEntity(
            mesh: .generateSphere(radius: 0.15),
            materials: [SimpleMaterial(color: .blue, isMetallic: false)]
        )
        // Add the fallback model as a child.
        self.addChild(fallbackModel)
        self.generateCollisionShapes(recursive: true)
    }
}

// MARK: - SIMD Helper Extensions
extension float4x4 {
    init(translation: SIMD3<Float>) {
        self.init(
            SIMD4(1, 0, 0, 0),
            SIMD4(0, 1, 0, 0),
            SIMD4(0, 0, 1, 0),
            SIMD4(translation, 1)
        )
    }
}
