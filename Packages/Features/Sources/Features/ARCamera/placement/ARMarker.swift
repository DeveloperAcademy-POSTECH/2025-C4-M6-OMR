import Combine
import DesignSystem
import Foundation
import RealityKit
import UIKit

class ARMarker: Entity, HasCollision {
    let record: ARRecordModel
    private var cancellables = Set<AnyCancellable>()

    // Main model entity
    private var mainModelEntity: ModelEntity?

    // For focus effect
    private var focusEntity: ModelEntity?
    private var focusOutlineEntity: ModelEntity?
    private var originalScale: SIMD3<Float> = SIMD3<Float>(1.0, 1.0, 1.0)

    // Focus state
    private var isFocused: Bool = false

    init(record: ARRecordModel) {
        self.record = record
        super.init()

        setupMarker()
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    private func setupMarker() {
        // First try to load the specific model
        loadModel(named: record.modelName)
            .catch { [weak self] error -> AnyPublisher<ModelEntity, Error> in
                print(
                    "Failed to load model '\(self?.record.modelName ?? "unknown")': \(error)"
                )
                // Try fallback model
                return self?.loadFallbackModel()
                    ?? Just(self?.createDefaultModel() ?? ModelEntity())
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("All model loading failed: \(error)")
                    }
                },
                receiveValue: { [weak self] modelEntity in
                    self?.setupMainModel(modelEntity)
                }
            )
            .store(in: &cancellables)
    }

    private func loadModel(named modelName: String) -> AnyPublisher<
        ModelEntity, Error
    > {
        // Try loading from main bundle first
        if let entity = try? Entity.load(named: modelName) as? ModelEntity {
            return Just(entity)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        // Try async loading from module
        return Entity.loadModelAsync(named: modelName, in: .module)
            .eraseToAnyPublisher()
    }

    private func loadFallbackModel() -> AnyPublisher<ModelEntity, Error> {
        return Entity.loadModelAsync(named: "test_flower")
            .catch { error -> AnyPublisher<ModelEntity, Error> in
                print("Fallback model loading failed: \(error)")
                return Just(self.createDefaultModel())
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func createDefaultModel() -> ModelEntity {
        let mesh = MeshResource.generateSphere(radius: 0.15)
        let material = SimpleMaterial(color: .systemBlue, isMetallic: false)
        return ModelEntity(mesh: mesh, materials: [material])
    }

    private func setupMainModel(_ modelEntity: ModelEntity) {
        // Ensure the model is visible and properly scaled
        modelEntity.scale = SIMD3<Float>(1.0, 1.0, 1.0)
        modelEntity.isEnabled = true

        // Add to scene hierarchy
        self.addChild(modelEntity)
        self.mainModelEntity = modelEntity
        self.originalScale = modelEntity.scale

        // Setup collision for tap detection
        setupCollisionDetection(for: modelEntity)

        // Create focus indicator (simple approach)
        setupFocusIndicator()

        print("✅ ARMarker setup completed for record: \(record.id)")
    }

    private func setupCollisionDetection(for modelEntity: ModelEntity) {
        // 1. 먼저 모델 자체의 충돌 형태 생성 시도
        if modelEntity.model?.mesh != nil {
            modelEntity.generateCollisionShapes(recursive: false)
            print("🎯 모델 기반 충돌 형태 생성됨")
        }

        // 2. 추가로 이 ARMarker 엔티티에도 충돌 박스 생성 (fallback)
        let collisionBox = CollisionComponent(
            shapes: [.generateBox(size: SIMD3<Float>(0.3, 0.3, 0.3))],
            mode: .trigger,
            filter: .default
        )
        self.components[CollisionComponent.self] = collisionBox

        print("🎯 ARMarker 충돌 감지 설정 완료")
    }

    // MARK: - Focus Effect Implementation (Simplified)

    private func setupFocusIndicator() {
        // 1. 글로우 효과 (납작한 구체)
        let glowMesh = MeshResource.generateSphere(radius: 0.3)
        let glowMaterial = SimpleMaterial(
            color: UIColor.systemYellow.withAlphaComponent(0.3),
            isMetallic: false
        )

        let focusGlow = ModelEntity(mesh: glowMesh, materials: [glowMaterial])
        focusGlow.scale = SIMD3<Float>(1.0, 0.1, 1.0)  // 납작한 디스크 형태로
        focusGlow.position = SIMD3<Float>(0, -0.15, 0)  // 모델 아래에 위치
        focusGlow.isEnabled = false  // 초기에는 숨김

        self.focusEntity = focusGlow
        self.addChild(focusGlow)

        // 2. 아웃라인 박스 (더 명확한 시각적 피드백)
        let outlineMesh = MeshResource.generateBox(size: 0.35)
        var outlineMaterial = UnlitMaterial()
        outlineMaterial.color = .init(tint: UIColor.systemYellow)

        let outlineBox = ModelEntity(
            mesh: outlineMesh,
            materials: [outlineMaterial]
        )
        outlineBox.scale = SIMD3<Float>(1.0, 1.0, 1.0)
        outlineBox.isEnabled = false

        self.focusOutlineEntity = outlineBox
        self.addChild(outlineBox)

        print("✅ Focus indicators setup completed")
    }

    // MARK: - Focus State Management

    func setFocus(isFocused: Bool) {
        print(
            "🎯 ARMarker.setFocus called: \(isFocused) for record: \(record.id)"
        )

        guard self.isFocused != isFocused else {
            print("⚠️ Focus state already set to: \(isFocused)")
            return
        }

        self.isFocused = isFocused

        if isFocused {
            showFocusEffect()
        } else {
            hideFocusEffect()
        }
    }

    private func showFocusEffect() {
        print("🎯 Showing focus effect for marker: \(record.id)")

        // 1. 포커스 글로우 표시
        if let focus = focusEntity {
            focus.isEnabled = true
            print("✅ Focus glow enabled")
        } else {
            print("❌ Focus entity is nil!")
        }

        // 2. 아웃라인 박스 표시
        if let outline = focusOutlineEntity {
            outline.isEnabled = true
            print("✅ Focus outline enabled")
        }

        // 3. 모델 스케일 애니메이션
        if let mainModel = mainModelEntity {
            print("🎯 Starting scale animation")
            // 즉시 약간 크게 만들기
            mainModel.scale = originalScale * 1.15

            // 부드러운 펄스 효과
            animatePulse()
        } else {
            print("❌ Main model entity is nil!")
        }

        // 4. 포커스 글로우 펄스 애니메이션
        if let focusGlow = focusEntity {
            animateFocusGlow(for: focusGlow)
        }

        // 5. 아웃라인 회전 애니메이션
        if let outline = focusOutlineEntity {
            animateOutlineRotation(for: outline)
        }
    }

    private func animateOutlineRotation(for entity: ModelEntity) {
        // Y축 회전 애니메이션
        var transform = entity.transform
        transform.rotation = simd_quatf(angle: .pi * 2, axis: [0, 1, 0])

        entity.move(
            to: transform,
            relativeTo: entity.parent,
            duration: 4.0,
            timingFunction: .linear
        )

        // 반복
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
            guard let self = self, self.isFocused else { return }
            entity.transform.rotation = simd_quatf()
            self.animateOutlineRotation(for: entity)
        }
    }

    private func hideFocusEffect() {
        print("🎯 Hiding focus effect for marker: \(record.id)")

        // 1. 포커스 글로우 숨기기
        focusEntity?.isEnabled = false

        // 2. 아웃라인 박스 숨기기
        focusOutlineEntity?.isEnabled = false

        // 3. 모델 원래 크기로
        if let mainModel = mainModelEntity {
            mainModel.stopAllAnimations()
            mainModel.scale = originalScale
        }

        // 4. 애니메이션 중지
        focusEntity?.stopAllAnimations()
        focusOutlineEntity?.stopAllAnimations()
    }

    private func animatePulse() {
        guard let mainModel = mainModelEntity else { return }

        // FromToByAnimation을 사용한 펄스 효과
        var transform = mainModel.transform
        transform.scale = originalScale * 1.15

        mainModel.move(
            to: transform,
            relativeTo: self,
            duration: 0.8,
            timingFunction: .easeInOut
        )

        // 반복을 위해 completion handler에서 다시 호출
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self, self.isFocused else { return }

            var transform2 = mainModel.transform
            transform2.scale = self.originalScale * 1.05

            mainModel.move(
                to: transform2,
                relativeTo: self,
                duration: 0.8,
                timingFunction: .easeInOut
            )

            // 계속 반복
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                [weak self] in
                if self?.isFocused == true {
                    self?.animatePulse()
                }
            }
        }
    }

    private func animateFocusGlow(for entity: ModelEntity) {
        // 글로우 펄스 애니메이션 (스케일 변화)
        var transform = entity.transform
        transform.scale = SIMD3<Float>(1.2, 0.12, 1.2)  // 더 크게

        entity.move(
            to: transform,
            relativeTo: entity.parent,
            duration: 1.0,
            timingFunction: .easeInOut
        )

        // 반복
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self, self.isFocused else { return }

            var transform2 = entity.transform
            transform2.scale = SIMD3<Float>(0.8, 0.08, 0.8)  // 더 작게

            entity.move(
                to: transform2,
                relativeTo: entity.parent,
                duration: 1.0,
                timingFunction: .easeInOut
            )

            // 계속 반복
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                [weak self] in
                if self?.isFocused == true {
                    self?.animateFocusGlow(for: entity)
                }
            }
        }
    }

    // MARK: - Debug Methods

    func debugInfo() -> String {
        return """
            ARMarker Debug Info:
            - Record ID: \(record.id)
            - Model Name: \(record.modelName)
            - Main Model: \(mainModelEntity != nil ? "✅" : "❌")
            - Focus Entity: \(focusEntity != nil ? "✅" : "❌")
            - Is Focused: \(isFocused)
            - Position: \(position)
            - Scale: \(scale)
            - Is Enabled: \(isEnabled)
            - Children Count: \(children.count)
            """
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
