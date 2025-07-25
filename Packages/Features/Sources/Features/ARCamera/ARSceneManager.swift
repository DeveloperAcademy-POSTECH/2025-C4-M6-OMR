import Foundation
import RealityKit
import ARKit
import Combine
import CoreLocation
import DesignSystem

@MainActor
class ARSceneManager: NSObject, ARSessionDelegate, ObservableObject {
    private(set) var arView: ARView?
    
    // 임시 배치 및 확정을 위한 프로퍼티
    var placementEntity: ModelEntity?
    private var placementAnchor: AnchorEntity?
    private var confirmedAnchor: AnchorEntity? // 확정된 앵커를 추적
    private var isPlacementConfirmed = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // 콜백
    var onRecordTapped: ((ARRecordModel) -> Void)?

    func setupARView(_ arView: ARView) {
        self.arView = arView
        arView.session.delegate = self
        setupGestures(on: arView)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)
    }
    
    // MARK: - Placement Logic
    
    func placeTemporaryObject(flower: ARFlower, statusUpdate: @escaping (String) -> Void) {
        removePlacementObject() // 기존 객체 제거
        isPlacementConfirmed = false
        statusUpdate("\(flower.name) 모델을 로드하는 중...")
        
        Entity.loadModelAsync(named: flower.modelName, in: .module)
            .catch { error -> AnyPublisher<ModelEntity, Error> in
                print("DEBUG: Failed to load original model '\(flower.modelName)': \(error)")
                statusUpdate("모델 로딩 실패. 임시 꽃 모델 대체합니다.")
                return Entity.loadModelAsync(named: "test_flower").eraseToAnyPublisher()
            }
            .catch { error -> AnyPublisher<ModelEntity, Error> in
                print("DEBUG: Failed to load fallback model 'test_flower.usdz': \(error)")
                statusUpdate("임시 모델 로딩도 실패했습니다. 기본 상자로 대체합니다.")
                let box = ModelEntity(mesh: .generateBox(size: 0.3), materials: [SimpleMaterial(color: .systemPink, isMetallic: false)])
                return Just(box).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    statusUpdate("오류: 모델을 로드할 수 없습니다. \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] modelEntity in
                self?.placementEntity = modelEntity
                statusUpdate("꽃을 배치할 위치를 정해주세요.")
            })
            .store(in: &cancellables)
    }
    
    func confirmPlacement() {
        guard let entity = placementEntity, let anchor = placementAnchor else { return }

        isPlacementConfirmed = true
        
        // 이전에 확정된 앵커가 있다면 제거합니다.
        if let oldConfirmedAnchor = confirmedAnchor {
            arView?.scene.removeAnchor(oldConfirmedAnchor)
        }

        // 새 영구 앵커를 생성하고, 추적합니다.
        let permanentAnchor = AnchorEntity(world: anchor.transform.matrix)
        permanentAnchor.addChild(entity.clone(recursive: true))
        arView?.scene.addAnchor(permanentAnchor)
        self.confirmedAnchor = permanentAnchor
        
        // 임시 배치 객체는 더 이상 필요 없으므로 제거합니다.
        arView?.scene.removeAnchor(anchor)
        self.placementAnchor = nil
    }
    
    func removePlacementObject() {
        // 임시 앵커 제거
        if let anchor = placementAnchor {
            arView?.scene.removeAnchor(anchor)
            self.placementAnchor = nil
        }
        // 확정된 앵커 제거
        if let anchor = confirmedAnchor {
            arView?.scene.removeAnchor(anchor)
            self.confirmedAnchor = nil
        }
        
        self.placementEntity = nil
        self.isPlacementConfirmed = false
    }

    func startRepositioning() {
        if let anchor = confirmedAnchor {
            arView?.scene.removeAnchor(anchor)
            self.confirmedAnchor = nil
        }
        isPlacementConfirmed = false
    }
    
    // MARK: - ARSessionDelegate
    
    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
        Task { @MainActor in
            // 임시 배치 객체가 있고, 아직 확정되지 않았을 때만 위치 업데이트
            guard let arView = self.arView, let entityToPlace = self.placementEntity, !self.isPlacementConfirmed else { return }

            let centerOfScreen = arView.center
            let raycastResults = arView.raycast(from: centerOfScreen, allowing: .estimatedPlane, alignment: .horizontal)

            if let firstResult = raycastResults.first {
                let targetPosition = SIMD3<Float>(firstResult.worldTransform.columns.3.x, firstResult.worldTransform.columns.3.y, firstResult.worldTransform.columns.3.z)

                // 카메라의 전방 벡터를 사용하여 기기의 방향을 가져옵니다.
                let cameraTransform = frame.camera.transform
                let forwardVector = -SIMD3<Float>(cameraTransform.columns.2.x, cameraTransform.columns.2.y, cameraTransform.columns.2.z)
                
                // 객체가 항상 수직을 유지하며 카메라를 향하도록 합니다.
                let horizontalForward = normalize(SIMD3<Float>(forwardVector.x, 0, forwardVector.z))
                
                // 사용자가 거의 수직으로 위나 아래를 볼 때 발생할 수 있는 불안정성을 방지합니다.
                guard length(SIMD2<Float>(horizontalForward.x, horizontalForward.z)) > 0.1 else { return }
                
                let zAxis = -horizontalForward
                let xAxis = normalize(cross(SIMD3<Float>(0, 1, 0), zAxis))
                let yAxis = cross(zAxis, xAxis)
                
                let newTransformMatrix = float4x4(
                    SIMD4(xAxis, 0),
                    SIMD4(yAxis, 0),
                    SIMD4(zAxis, 0),
                    SIMD4(targetPosition, 1)
                )

                // 앵커의 위치와 방향을 업데이트합니다.
                if let placementAnchor = self.placementAnchor {
                    placementAnchor.transform.matrix = newTransformMatrix
                } else {
                    let newAnchor = AnchorEntity(world: newTransformMatrix)
                    newAnchor.addChild(entityToPlace)
                    arView.scene.addAnchor(newAnchor)
                    self.placementAnchor = newAnchor
                }
                
                if !entityToPlace.isEnabled {
                    entityToPlace.isEnabled = true
                }
            } else {
                if entityToPlace.isEnabled {
                    entityToPlace.isEnabled = false
                }
            }
        }
    }
    
    // MARK: - Gesture Handling
    private func setupGestures(on view: ARView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        guard let arView else { return }
        
        let location = sender.location(in: arView)
        if let tappedEntity = arView.entity(at: location) {
            // ARMarker 또는 그 자식 요소를 탭했는지 확인
            if let marker = findARMarker(in: tappedEntity) {
                onRecordTapped?(marker.record)
            }
        }
    }
    
    private func findARMarker(in entity: Entity) -> ARMarker? {
        var currentEntity: Entity? = entity
        while currentEntity != nil {
            if let marker = currentEntity as? ARMarker {
                return marker
            }
            currentEntity = currentEntity?.parent
        }
        return nil
    }
    
    // MARK: - Record Handling
    func updateSceneWithRecords(records: [ARRecordModel], userLocation: CLLocation, userHeading: CLHeading, transformUseCase: TransformCoordinateUseCase) {
        // ... (기존 코드는 동일)
    }
}

// ... (SIMD Helper는 동일)

