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
        
        setupCollision()
        loadModel()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    private func setupCollision() {
        generateCollisionShapes(recursive: true)
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
                    if let modelComponent = modelEntity.components[ModelComponent.self] {
                        self?.components.set(modelComponent)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func setupFallbackModel() {
        let fallbackModel = ModelComponent(
            mesh: .generateSphere(radius: 0.15),
            materials: [SimpleMaterial(color: .blue, isMetallic: false)]
        )
        components.set(fallbackModel)
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
