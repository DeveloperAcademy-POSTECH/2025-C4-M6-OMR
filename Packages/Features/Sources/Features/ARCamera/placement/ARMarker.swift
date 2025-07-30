import Combine
import DesignSystem
import Foundation
import RealityKit
import UIKit

// 🔥 JSON 파일을 위한 데이터 구조체들
struct DiamondIndicatorData: Codable {
    let vertices: [Vertex]
    let faces: [Face]
    let materials: [MaterialData]?
    let scale: Float?
    let position: Position?
}

struct Vertex: Codable {
    let x: Float
    let y: Float
    let z: Float
}

struct Face: Codable {
    let indices: [UInt32]
    let materialIndex: Int?
}

struct MaterialData: Codable {
    let color: ColorData?
    let metallic: Float?
    let roughness: Float?
    let emission: ColorData?
}

struct ColorData: Codable {
    let r: Float
    let g: Float
    let b: Float
    let a: Float?
}

struct Position: Codable {
    let x: Float
    let y: Float
    let z: Float
}

class ARMarker: Entity, HasCollision {
    let record: ARRecordModel
    private var cancellables = Set<AnyCancellable>()

    // Main model entity
    private var mainModelEntity: ModelEntity?
    
    // 🔥 다이아몬드 인디케이터 추가
    private var diamondIndicator: ModelEntity?

    // For focus effect
    private var focusEntity: ModelEntity?
    private var focusOutlineEntity: ModelEntity?
    private var originalScale: SIMD3<Float> = SIMD3<Float>(1.0, 1.0, 1.0)

    // Focus state
    private var isFocused: Bool = false

    init(record: ARRecordModel, showDiamond: Bool = true) {
        self.record = record
        super.init()

        setupMarker()
        
        // 🔥 다이아몬드 인디케이터 로드
        if showDiamond {
            setupDiamondIndicatorFromJSON()
        }
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

    // 🔥 JSON에서 다이아몬드 인디케이터 로드
    private func setupDiamondIndicatorFromJSON() {
        loadDiamondFromJSON(filename: "indicator_diamond")
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to load diamond from JSON: \(error)")
                        // JSON 로드 실패 시 기본 다이아몬드 생성
                        DispatchQueue.main.async { [weak self] in
                            let defaultDiamond = self?.createDefaultDiamond() ?? ModelEntity()
                            self?.setupDiamond(defaultDiamond)
                        }
                    }
                },
                receiveValue: { [weak self] diamondEntity in
                    self?.setupDiamond(diamondEntity)
                }
            )
            .store(in: &cancellables)
    }

    private func loadDiamondFromJSON(filename: String) -> AnyPublisher<ModelEntity, Error> {
        return Future<ModelEntity, Error> { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    // 1. JSON 파일 읽기
                    guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
                          let data = try? Data(contentsOf: url) else {
                        throw NSError(domain: "ARMarker", code: 1, userInfo: [NSLocalizedDescriptionKey: "JSON file not found"])
                    }
                    
                    // 2. JSON 파싱
                    let diamondData = try JSONDecoder().decode(DiamondIndicatorData.self, from: data)
                    
                    // 3. ModelEntity 생성을 메인 스레드에서 실행
                    DispatchQueue.main.async {
                        do {
                            let modelEntity = try self.createModelFromJSON(diamondData)
                            promise(.success(modelEntity))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    // 🔥 노멀 벡터 계산 헬퍼 함수
    private func calculateNormals(positions: [SIMD3<Float>], indices: [UInt32]) -> [SIMD3<Float>] {
        var normals = Array(repeating: SIMD3<Float>(0, 0, 0), count: positions.count)
        
        // 각 삼각형의 노멀 벡터 계산
        for i in stride(from: 0, to: indices.count, by: 3) {
            let i0 = Int(indices[i])
            let i1 = Int(indices[i + 1])
            let i2 = Int(indices[i + 2])
            
            let v0 = positions[i0]
            let v1 = positions[i1]
            let v2 = positions[i2]
            
            // 외적으로 노멀 벡터 계산
            let edge1 = v1 - v0
            let edge2 = v2 - v0
            let normal = normalize(cross(edge1, edge2))
            
            // 각 버텍스에 노멀 벡터 누적
            normals[i0] += normal
            normals[i1] += normal
            normals[i2] += normal
        }
        
        // 노멀 벡터 정규화
        return normals.map { normalize($0) }
    }

    @MainActor
    private func createModelFromJSON(_ data: DiamondIndicatorData) throws -> ModelEntity {
        // 1. 버텍스 데이터를 SIMD3<Float> 배열로 변환
        let positions = data.vertices.map { vertex in
            SIMD3<Float>(vertex.x, vertex.y, vertex.z)
        }
        
        // 2. 면 데이터를 인덱스 배열로 변환 (삼각형 기준)
        var indices: [UInt32] = []
        for face in data.faces {
            // 사각형인 경우 두 개의 삼각형으로 분할
            if face.indices.count == 4 {
                indices.append(contentsOf: [
                    face.indices[0], face.indices[1], face.indices[2],
                    face.indices[0], face.indices[2], face.indices[3]
                ])
            } else if face.indices.count == 3 {
                indices.append(contentsOf: face.indices)
            }
        }
        
        // 3. 메시 리소스 생성
        var meshDescriptor = MeshDescriptor()
        meshDescriptor.positions = MeshBuffers.Positions(positions)
        meshDescriptor.primitives = .triangles(indices)
        
        // 4. 노멀 벡터 수동 계산 (generatingNormals가 없는 경우)
        let normals = calculateNormals(positions: positions, indices: indices)
        meshDescriptor.normals = MeshBuffers.Normals(normals)
        
        let meshResource = try MeshResource.generate(from: [meshDescriptor])
        
        // 5. 재질 생성
        let materials = createMaterialsFromJSON(data.materials)
        
        // 6. ModelEntity 생성
        let modelEntity = ModelEntity(mesh: meshResource, materials: materials)
        
        // 7. 스케일 및 위치 적용
        if let scale = data.scale {
            modelEntity.scale = SIMD3<Float>(scale, scale, scale)
        }
        
        if let position = data.position {
            modelEntity.position = SIMD3<Float>(position.x, position.y, position.z)
        }
        
        return modelEntity
    }

    @MainActor
    private func createMaterialsFromJSON(_ materialsData: [MaterialData]?) -> [Material] {
        guard let materialsData = materialsData, !materialsData.isEmpty else {
            // 기본 다이아몬드 재질
            var defaultMaterial = SimpleMaterial()
            defaultMaterial.color = .init(tint: UIColor.systemCyan)
            defaultMaterial.metallic = .init(floatLiteral: 0.8)
            defaultMaterial.roughness = .init(floatLiteral: 0.1)
            return [defaultMaterial]
        }
        
        return materialsData.map { materialData in
            var material = SimpleMaterial()
            
            // 색상 설정
            if let colorData = materialData.color {
                let color = UIColor(
                    red: CGFloat(colorData.r),
                    green: CGFloat(colorData.g),
                    blue: CGFloat(colorData.b),
                    alpha: CGFloat(colorData.a ?? 1.0)
                )
                material.color = .init(tint: color)
            }
            
            // 메탈릭 설정
            if let metallic = materialData.metallic {
                material.metallic = .init(floatLiteral: metallic)
            }
            
            // 거칠기 설정
            if let roughness = materialData.roughness {
                material.roughness = .init(floatLiteral: roughness)
            }
            
            // 발광 설정
            if let emission = materialData.emission {
                let emissionColor = UIColor(
                    red: CGFloat(emission.r),
                    green: CGFloat(emission.g),
                    blue: CGFloat(emission.b),
                    alpha: CGFloat(emission.a ?? 1.0)
                )
                // SimpleMaterial에서는 발광을 직접 지원하지 않으므로 색상에 밝기를 더함
                material.color = .init(tint: emissionColor)
            }
            
            return material
        }
    }

    private func createDefaultDiamond() -> ModelEntity {
        // JSON 로드 실패 시 기본 다이아몬드 생성
        let positions: [SIMD3<Float>] = [
            // 상단 피라미드
            SIMD3<Float>(0, 0.1, 0),      // 상단 꼭짓점
            SIMD3<Float>(-0.05, 0, -0.05), // 사각형 베이스
            SIMD3<Float>(0.05, 0, -0.05),
            SIMD3<Float>(0.05, 0, 0.05),
            SIMD3<Float>(-0.05, 0, 0.05),
            
            // 하단 피라미드
            SIMD3<Float>(0, -0.1, 0),     // 하단 꼭짓점
        ]
        
        let indices: [UInt32] = [
            // 상단 피라미드 면들
            0, 1, 2,  0, 2, 3,  0, 3, 4,  0, 4, 1,
            // 하단 피라미드 면들
            5, 2, 1,  5, 3, 2,  5, 4, 3,  5, 1, 4
        ]
        
        var meshDescriptor = MeshDescriptor()
        meshDescriptor.positions = MeshBuffers.Positions(positions)
        meshDescriptor.primitives = .triangles(indices)
        
        // 노멀 벡터 수동 계산
        let normals = calculateNormals(positions: positions, indices: indices)
        meshDescriptor.normals = MeshBuffers.Normals(normals)
        
        guard let meshResource = try? MeshResource.generate(from: [meshDescriptor]) else {
            // 최종 백업: 단순한 박스
            let mesh = MeshResource.generateBox(size: SIMD3<Float>(0.1, 0.1, 0.1))
            var material = SimpleMaterial(color: .systemCyan, isMetallic: true)
            material.roughness = .init(floatLiteral: 0.1)
            let diamond = ModelEntity(mesh: mesh, materials: [material])
            diamond.transform.rotation = simd_quatf(angle: .pi/4, axis: [0, 1, 0]) *
                                       simd_quatf(angle: .pi/4, axis: [1, 0, 0])
            return diamond
        }
        
        var material = SimpleMaterial()
        material.color = .init(tint: UIColor.systemCyan)
        material.metallic = .init(floatLiteral: 0.8)
        material.roughness = .init(floatLiteral: 0.1)
        
        return ModelEntity(mesh: meshResource, materials: [material])
    }

    private func setupDiamond(_ diamondEntity: ModelEntity) {
        // 다이아몬드 크기 및 위치 설정
        diamondEntity.scale = SIMD3<Float>(1.5, 1.5, 1.5)
        diamondEntity.position = SIMD3<Float>(0, 1.5, 0)
        
        // 다이아몬드를 ARMarker에 추가
        self.addChild(diamondEntity)
        self.diamondIndicator = diamondEntity
        
        // 다이아몬드 회전 애니메이션 시작
        startDiamondRotation()
        
        print("✅ Diamond indicator setup completed")
    }

    // 🔥 다이아몬드 회전 애니메이션 (펄스 효과 제거)
    private func startDiamondRotation() {
        guard let diamond = diamondIndicator else { return }
        
        var transform = diamond.transform
        transform.rotation = simd_quatf(angle: .pi * 2, axis: [0, 1, 0])
        
        diamond.move(
            to: transform,
            relativeTo: diamond.parent,
            duration: 3.0,
            timingFunction: .linear
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self = self, self.diamondIndicator != nil else { return }
            diamond.transform.rotation = simd_quatf()
            self.startDiamondRotation()
        }
    }

    // 🔥 다이아몬드 관련 공개 메서드들
    
    /// 다이아몬드 표시/숨김
    func setDiamondVisible(_ visible: Bool, animated: Bool = true) {
        guard let diamond = diamondIndicator else { return }
        
        if animated {
            if visible {
                diamond.isEnabled = true
                diamond.scale = SIMD3<Float>(0, 0, 0)
                
                var transform = diamond.transform
                transform.scale = SIMD3<Float>(1.5, 1.5, 1.5) // 고정 크기로 변경
                
                diamond.move(
                    to: transform,
                    relativeTo: diamond.parent,
                    duration: 0.3,
                    timingFunction: .easeOut
                )
            } else {
                var transform = diamond.transform
                transform.scale = SIMD3<Float>(0, 0, 0)
                
                diamond.move(
                    to: transform,
                    relativeTo: diamond.parent,
                    duration: 0.3,
                    timingFunction: .easeIn
                )
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    diamond.isEnabled = false
                }
            }
        } else {
            diamond.isEnabled = visible
        }
    }

    /// 다이아몬드 높이 조정
    func setDiamondHeight(_ height: Float, animated: Bool = true) {
        guard let diamond = diamondIndicator else { return }
        
        let newPosition = SIMD3<Float>(0, height, 0)
        
        if animated {
            var transform = diamond.transform
            transform.translation = newPosition
            
            diamond.move(
                to: transform,
                relativeTo: diamond.parent,
                duration: 0.5,
                timingFunction: .easeInOut
            )
        } else {
            diamond.position = newPosition
        }
    }

    // 펄스 효과 함수 제거됨

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

    // MARK: - Focus Effect Implementation (펄스 제거)

    private func setupFocusIndicator() {
        // 1. 글로우 효과 (납작한 구체) - 고정 크기
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

    // MARK: - Focus State Management (펄스 효과 제거)

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

        // 포커스 인디케이터가 설정되지 않았다면 설정
        if focusEntity == nil || focusOutlineEntity == nil {
            setupFocusIndicator()
        }

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

        // 3. 모델 스케일 고정 (펠스 제거)
        if let mainModel = mainModelEntity {
            print("🎯 Setting fixed scale")
            mainModel.scale = originalScale * 1.15 // 고정 크기로 설정
        } else {
            print("❌ Main model entity is nil!")
        }

        // 4. 아웃라인 회전 애니메이션만 유지
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

    // 펄스 애니메이션 함수들 제거됨

    // MARK: - Debug Methods

    func debugInfo() -> String {
        return """
            ARMarker Debug Info:
            - Record ID: \(record.id)
            - Model Name: \(record.modelName)
            - Main Model: \(mainModelEntity != nil ? "✅" : "❌")
            - Diamond Indicator: \(diamondIndicator != nil ? "✅" : "❌")
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
