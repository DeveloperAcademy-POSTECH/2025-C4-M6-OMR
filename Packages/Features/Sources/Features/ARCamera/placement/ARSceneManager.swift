import ARKit
import Combine
import CoreLocation
import RealityKit
import SwiftUI
import UIKit

@MainActor
class ARSceneManager: NSObject, ARSessionDelegate, ObservableObject {
    
    // MARK: - Properties
    private(set) var arView: ARView?
    private var cameraManager: ARCameraManager?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Placement Management
    private var placementState = ARPlacementState()
    var placementEntity: ModelEntity? { placementState.entity }
    
    // MARK: - Scene Management
    private var recordMarkers: [UUID: ARMarker] = [:]
    private var selectedMarker: ARMarker?
    
    // MARK: - Placement Indicator
    private var placementIndicator: ModelEntity?
    private var placementPosition: SIMD3<Float>?
    private var currentFlowerAnchor: AnchorEntity? // 현재 배치된 꽃 앵커 추적
    
    private var lastIndicatorUpdateTime: TimeInterval = 0
    private let indicatorUpdateInterval: TimeInterval = 1.0 / 10.0 // 10 FPS로 최적화 (성능 향상)
    private let smootingFactor: Float = 0.2 // 스무딩 계수 조정 (부드러운 움직임)
    
    
    // MARK: - Callbacks
    var onRecordTapped: ((ARRecordModel) -> Void)?
    var onPlacementStateChanged: ((ARPlacementState.Status) -> Void)?
    var onFocusStateChanged: ((Bool) -> Void)?
    
    // MARK: - Setup
    func setup(arView: ARView) {
        
        self.arView = arView
        self.cameraManager = ARCameraManager(arView: arView)
        
        // 델리게이트 설정 추가
        self.cameraManager?.delegate = self
        
        arView.session.delegate = self
        setupGestures(on: arView)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)
        
        
    }
    
    // MARK: - Placement Logic
    func placeTemporaryObject(
        flower: ARFlower,
        statusUpdate: @escaping (String) -> Void
    ) {
        placementState.reset()
        statusUpdate("\(flower.name) 모델을 로드하는 중...")
        
        loadModelWithFallback(modelName: flower.modelName, flower: flower)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        statusUpdate("모델 로딩 실패: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] modelEntity in
                    self?.placementState.setEntity(modelEntity, flower: flower)
                    self?.createPlacementIndicator() // 인디케이터 생성
                    self?.onPlacementStateChanged?(
                        self?.placementState.status ?? .idle
                    )
                    statusUpdate("🔴 빨간 인디케이터 위치에 \(flower.name)이(가) 배치됩니다. 확인 버튼을 눌러주세요.")
                }
            )
            .store(in: &cancellables)
    }
    
    func confirmPlacement() {
        guard placementState.canConfirm,
              let arView = arView,
              let position = placementPosition else { return }
        
        // 인디케이터 위치에 꽃 생성
        if let entity = placementState.entity {
            let flowerAnchor = AnchorEntity(world: position)
            flowerAnchor.addChild(entity.clone(recursive: true))
            arView.scene.addAnchor(flowerAnchor)
            
            // 현재 꽃 앵커 추적 (재배치 시 제거용)
            self.currentFlowerAnchor = flowerAnchor
            print("🌸 꽃 생성됨 - 위치: \(position)")
        }
        
        placementState.confirm()
        removePlacementIndicator() // 인디케이터 제거
        onPlacementStateChanged?(placementState.status)
    }
    
    func removePlacementObject() {
        if let arView = arView {
            placementState.removeFrom(arView: arView)
        }
        removePlacementIndicator() // 인디케이터 제거
        onPlacementStateChanged?(placementState.status)
    }
    
    func startRepositioning() {
        guard placementState.status == .confirmed else { return }
        
        // 기존 꽃 제거
        if let arView = arView, let existingFlower = currentFlowerAnchor {
            arView.scene.removeAnchor(existingFlower)
            currentFlowerAnchor = nil
            print("🗑️ 기존 꽃 제거됨 - 재배치 준비")
        }
        
        if let arView = arView {
            placementState.startRepositioning(in: arView)
        }
        createPlacementIndicator() // 재배치 시 새로운 인디케이터 생성
        onPlacementStateChanged?(placementState.status)
    }
    
    // MARK: - Record Handling
    func updateSceneWithRecords(
        records: [ARRecordModel],
        userLocation: CLLocation,
        userHeading: CLHeading,
        transformUseCase: TransformCoordinateUseCase
    ) {
        guard let arView = arView else {
            print("❌ ARView가 없음 - updateSceneWithRecords 실패")
            return
        }
        
        print("🔄 업데이트할 레코드 수: \(records.count)")
        
        removeObsoleteMarkers(currentRecords: records)
        
        for record in records {
            if recordMarkers[record.id] == nil {
                let recordCoordinate = CLLocationCoordinate2D(
                    latitude: record.coordinate.latitude,
                    longitude: record.coordinate.longitude
                )
                
                // 범위 내에 있는지 먼저 확인
                if !transformUseCase.isWithinDisplayRange(
                    from: userLocation.coordinate,
                    to: recordCoordinate
                ) {
                    print("⚠️ Record \(record.id) 범위 밖 - 스킵")
                    continue
                }
                
                let arPosition = transformUseCase.transform(
                    userCoordinate: userLocation.coordinate,
                    userHeading: userHeading,
                    targetCoordinate: recordCoordinate
                )
                
                print("📍 Record \(record.id) 변환된 위치: \(arPosition)")
                
                // 추가 안전 검사
                let distance = length(arPosition)
                if distance > 100.0 || distance < 0.1 || arPosition.x.isNaN
                    || arPosition.z.isNaN
                {
                    print("⚠️ 비정상적인 위치값: \(distance)m - 스킵")
                    continue
                }
                
                createMarkerForRecord(record, at: arPosition, arView: arView)
            }
        }
        
        print("🎯 현재 씬의 마커 수: \(recordMarkers.count)")
    }
    
    private func removeObsoleteMarkers(currentRecords: [ARRecordModel]) {
        let currentRecordIds = Set(currentRecords.map { $0.id })
        
        for (recordId, marker) in recordMarkers {
            if !currentRecordIds.contains(recordId) {
                marker.parent?.removeFromParent()
                recordMarkers.removeValue(forKey: recordId)
                print("🗑️ 마커 제거: \(recordId)")
            }
        }
    }
    
    private func createMarkerForRecord(
        _ record: ARRecordModel,
        at position: SIMD3<Float>,
        arView: ARView
    ) {
        print("🏗️ 마커 생성 시작: \(record.id)")
        
        let marker = ARMarker(record: record)
        marker.generateCollisionShapes(recursive: true)
        let anchor = AnchorEntity(world: position)
        
        // 디버깅을 위한 이름 설정
        marker.name = "ARMarker_\(record.id)"
        anchor.name = "Anchor_\(record.id)"
        
        anchor.addChild(marker)
        arView.scene.addAnchor(anchor)
        recordMarkers[record.id] = marker
        
        print("✅ 마커 생성 완료: \(record.id) at \(position)")
        print("🔧 마커 이름: \(marker.name), 앵커 이름: \(anchor.name)")
        
        // 2초 후 마커 상태 확인
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            print("🔍 마커 상태 확인: \(marker.debugInfo())")
            print(
                "🔍 마커 충돌 컴포넌트: \(marker.components[CollisionComponent.self] != nil ? "있음" : "없음")"
            )
        }
    }
    
    func deselectCurrentMarker() {
        selectedMarker?.setFocus(isFocused: false)
        selectedMarker = nil
        cameraManager?.resetFocus()
    }
    
    // MARK: - Model Loading
    private func loadModelWithFallback(modelName: String, flower: ARFlower)
    -> AnyPublisher<ModelEntity, Error>
    {
        Entity.loadModelAsync(named: modelName, in: .module)
            .catch { error -> AnyPublisher<ModelEntity, Error> in
                print("Failed to load model '\(modelName)': \(error)")
                return Entity.loadModelAsync(named: "test_flower")
                    .eraseToAnyPublisher()
            }
            .catch { error -> AnyPublisher<ModelEntity, Error> in
                print("Failed to load fallback model: \(error)")
                let fallbackModel = ModelEntity(
                    mesh: .generateBox(size: 0.3),
                    materials: [
                        SimpleMaterial(color: .systemPink, isMetallic: false)
                    ]
                )
                return Just(fallbackModel)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - ARSessionDelegate
    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
        Task { @MainActor in
            // 배치 모드가 아니면 바로 종료 (성능 최적화)
            guard self.placementState.status == .placing,
                  let indicator = self.placementIndicator else { return }
            
            let currentTime = frame.timestamp
            guard currentTime - self.lastIndicatorUpdateTime > self.indicatorUpdateInterval else {
                return
            }
            self.lastIndicatorUpdateTime = currentTime
            
            // Raycast 수행 및 위치 업데이트
            if let targetPosition = self.getPlacementPositionFromRaycast() {
                let newPosition = lerp(
                    start: indicator.position,
                    end: targetPosition,
                    t: self.smootingFactor
                )
                indicator.position = newPosition
                self.placementPosition = newPosition
            }
        }
    }
    // Preview flower 표시 코드 제거됨
    
    // MARK: - Placement Indicator Management
    
    private func getPlacementPositionFromRaycast() -> SIMD3<Float>? {
        guard let arView = arView else { return nil }
        
        // 화면 중앙에서 레이캐스트 수행
        let screenCenter = arView.center
        let raycastResults = arView.raycast(
            from: screenCenter,
            allowing: .estimatedPlane, // 추정된 평면도 포함
            alignment: .horizontal
        )
        
        // 가장 먼저 감지된 결과의 월드 좌표를 반환
        return raycastResults.first?.worldTransform.columns.3.xyz
    }
    
    private func getFallbackPlacementPosition() -> SIMD3<Float>? {
        guard let arView = arView,
              let currentFrame = arView.session.currentFrame else {
            return nil
        }
        
        let cameraTransform = currentFrame.camera.transform
        let cameraPosition = SIMD3<Float>(
            cameraTransform.columns.3.x,
            cameraTransform.columns.3.y,
            cameraTransform.columns.3.z
        )
        
        let forwardDirection = -SIMD3<Float>(
            cameraTransform.columns.2.x,
            cameraTransform.columns.2.y,
            cameraTransform.columns.2.z
        )
        
        let placementDistance: Float = 3.0 // 3m 앞 고정 거리
        let targetPosition = cameraPosition + (normalize(forwardDirection) * placementDistance)
        
        return targetPosition
    }
    
    private func createPlacementIndicator() {
        guard let arView = arView else { return }
        
        // 1차: Raycast 시도
        var position = getPlacementPositionFromRaycast()
        
        // 2차: Fallback - 카메라 앞 3m 고정 거리
        if position == nil {
            position = getFallbackPlacementPosition()
            
        }
        
        guard let finalPosition = position else {
            print("❌ 배치 위치를 계산할 수 없습니다")
            return
        }
        
        // 기존 인디케이터 제거
        removePlacementIndicator()
        
        // 빨간색 원형 인디케이터 생성
        let radius: Float = 0.2
        let indicatorMesh = MeshResource.generateSphere(radius: radius)
        
        var material = SimpleMaterial()
        material.color = .init(tint: UIColor.red)
        material.roughness = 0.0
        material.metallic = 0.0
        
        let indicator = ModelEntity(mesh: indicatorMesh, materials: [material])
        
        let indicatorAnchor = AnchorEntity(world: finalPosition)
        indicatorAnchor.addChild(indicator)
        arView.scene.addAnchor(indicatorAnchor)
        
        self.placementIndicator = indicator
        self.placementPosition = finalPosition
        
        
    }
    
    private func removePlacementIndicator() {
        if let indicator = placementIndicator {
            indicator.removeFromParent()
            self.placementIndicator = nil
            self.placementPosition = nil
            
        }
    }
    
    // MARK: - Gesture Handling
    private func setupGestures(on view: ARView) {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTap(_:))
        )
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        guard let arView = arView else { return }
        
        let location = sender.location(in: arView)
        
        // 가장 위에 있는 엔티티만으로도 충분할 수 있습니다.
        if let tappedEntity = arView.entity(at: location),
           let tappedMarker = findARMarker(in: tappedEntity) {
            print("🎯 충돌 감지로 마커 발견: \(tappedMarker.record.id)")
            handleMarkerTap(tappedMarker)
        } else {
            print("❌ 마커를 찾을 수 없음")
            handleEmptySpaceTap()
        }
    }
    
    private func handleMarkerTap(_ marker: ARMarker) {
        print("🎯 handleMarkerTap called for marker: \(marker.record.id)")
        
        if marker !== selectedMarker {
            // 이전 마커의 포커스 해제
            if let prevMarker = selectedMarker {
                print(
                    "🎯 Removing focus from previous marker: \(prevMarker.record.id)"
                )
                prevMarker.setFocus(isFocused: false)
            }
            
            // 새 마커에 포커스
            print("🎯 Setting focus on new marker: \(marker.record.id)")
            marker.setFocus(isFocused: true)
            
            // 카메라 매니저에 포커스 요청
            cameraManager?.focus(on: marker)
            
            // 콜백 호출
            onRecordTapped?(marker.record)
            
            // 선택된 마커 업데이트
            selectedMarker = marker
        } else {
            // 같은 마커를 다시 탭한 경우 선택 해제
            print("🎯 Deselecting marker: \(marker.record.id)")
            deselectCurrentMarker()
        }
    }
    
    private func handleEmptySpaceTap() {
        selectedMarker?.setFocus(isFocused: false)
        selectedMarker = nil
        cameraManager?.resetFocus()
    }
    
    private func findNearestMarkerToScreenPoint(
        _ screenPoint: CGPoint,
        in arView: ARView
    ) -> ARMarker? {
        var nearestMarker: ARMarker?
        var nearestDistance: Float = Float.greatestFiniteMagnitude
        
        for marker in recordMarkers.values {
            // 마커의 월드 좌표를 스크린 좌표로 변환
            let markerWorldPosition = marker.position(relativeTo: nil)
            let screenPosition = arView.project(markerWorldPosition)
            
            // 스크린 좌표가 유효한지 확인
            guard screenPosition != nil else { continue }
            
            // 탭 위치와의 거리 계산
            let distance = sqrt(
                pow(Float(screenPosition!.x - screenPoint.x), 2)
                + pow(Float(screenPosition!.y - screenPoint.y), 2)
            )
            
            // 일정 거리 내에 있고 가장 가까운 마커 선택
            if distance < 100.0 && distance < nearestDistance {  // 100픽셀 이내
                nearestDistance = distance
                nearestMarker = marker
            }
        }
        
        if let marker = nearestMarker {
            print("📏 가장 가까운 마커 거리: \(nearestDistance)px")
        }
        
        return nearestMarker
    }
    
    private func findARMarker(in entity: Entity) -> ARMarker? {
        var currentEntity: Entity? = entity
        while let entity = currentEntity {
            if let marker = entity as? ARMarker {
                return marker
            }
            currentEntity = entity.parent
        }
        return nil
    }
    
    private func lerp(start: SIMD3<Float>, end: SIMD3<Float>, t: Float) -> SIMD3<Float> {
        return start + (end - start) * t
    }
}

// MARK: - ARCameraManagerDelegate
extension ARSceneManager: ARCameraManagerDelegate {
    func cameraManagerDidUpdateFocusState(isFocused: Bool) {
        // 포커스 상태 변화를 상위 레이어에 전달
        onFocusStateChanged?(isFocused)
        
        print("📷 Camera focus state changed: \(isFocused)")
    }
}

extension SIMD4<Float> {
    /// SIMD4<Float>의 x, y, z 요소를 사용하여 SIMD3<Float>를 반환합니다.
    var xyz: SIMD3<Float> {
        return SIMD3<Float>(x, y, z)
    }
}

