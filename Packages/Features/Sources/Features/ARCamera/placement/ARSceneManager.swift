import ARKit
import Combine
import CoreLocation
import RealityKit
import SwiftUI
import UIKit
import simd

@available(iOS 18.0, *)
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
    
    // MARK: - Placement Anchor (Single Source of Truth)
    private var placementAnchor: AnchorEntity?
    private var currentFlowerAnchor: AnchorEntity? // 현재 배치된 꽃 앵커 추적
    
    // MARK: - Location Tracking
    private var arSessionStartLocation: CLLocation? // AR 세션 시작 시 위치
    private var arSessionStartHeading: CLHeading? // AR 세션 시작 시 헤딩
    private var currentUserLocation: CLLocation? // 현재 사용자 위치
    private var currentUserHeading: CLHeading? // 현재 사용자 헤딩
    
    
    
    private let smoothingFactor: Float = 0.15 // 더 부드러운 스무딩
    private var isRaycastActive: Bool = false // raycast 활성화 상태
    
    // MARK: - Raycast Throttling (Thread-Safe)
    nonisolated(unsafe) private var lastRaycastTime: TimeInterval = 0
    private let raycastInterval: TimeInterval = 1.0 / 20.0 // 20 FPS로 레이캐스트 주기 설정
    nonisolated(unsafe) private var targetPosition: SIMD3<Float>?

    // MARK: - Callbacks
    var onRecordTapped: ((ARRecordModel) -> Void)?
    var onPlacementStateChanged: ((ARPlacementState.Status) -> Void)?
    var onFocusStateChanged: ((Bool) -> Void)?
    var onHeadingUpdated: ((Double, String) -> Void)? // 각도, 방향 문자열
    var onCameraOrientationUpdated: ((Double, String) -> Void)?
    
    
    @Published var raycastStatus: RaycastStatus = .idle
    @Published var lastRaycastDistance: Float = 0.0
    
    // 🆕 빠른 카메라 움직임 감지
    private var lastCameraPosition: SIMD3<Float>?
    private var lastUpdateTime: TimeInterval = 0

    private func shouldForceUpdate(currentCameraPosition: SIMD3<Float>) -> Bool {
        let currentTime = CACurrentMediaTime()
        
        defer {
            lastCameraPosition = currentCameraPosition
            lastUpdateTime = currentTime
        }
        
        guard let lastPos = lastCameraPosition else {
            return true // 첫 번째 업데이트
        }
        
        let deltaTime = currentTime - lastUpdateTime
        guard deltaTime > 0.016 else { return false } // 60fps 제한
        
        let distance = length(currentCameraPosition - lastPos)
        let velocity = distance / Float(deltaTime)
        
        // 빠른 움직임 감지 (초당 30cm 이상 이동)
        return velocity > 0.1
    }

    
    enum RaycastStatus {
        case idle
        case success(distance: Float)
        case fallback(distance: Float)
        case failed
        
        var displayText: String {
            switch self {
            case .idle:
                return "대기 중"
            case .success(let distance):
                return "평면 감지됨 (\(String(format: "%.2f", distance))m)"
            case .fallback(let distance):
                return "추정 위치 (\(String(format: "%.2f", distance))m)"
            case .failed:
                return "감지 실패"
            }
        }
        
        var color: UIColor {
            switch self {
            case .idle:
                return .systemGray
            case .success:
                return .systemGreen
            case .fallback:
                return .systemOrange
            case .failed:
                return .systemRed
            }
        }
        
        var success : Bool {
            switch self {
            case .idle:
                return false
            case .success:
                return true
            case .fallback:
                return false
            case .failed:
                return false
            }
        }
    }
    
    
    
    // MARK: - Setup
    func setup(arView: ARView) {
        
        self.arView = arView
        self.cameraManager = ARCameraManager(arView: arView)
        
        // 델리게이트 설정 추가
        self.cameraManager?.delegate = self
        
        arView.session.delegate = self
        setupGestures(on: arView)
        setupSceneUpdateSubscription(arView: arView)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)
        
        
    }
    
    // MARK: - AR Session Control
    
    /// AR 세션을 일시정지합니다 (배터리 절약)
    func pauseARSession() {
        guard let arView = arView else { return }
        
        print("⏸️ AR 세션 일시정지 - 배터리 절약 모드")
        arView.session.pause()
    }
    
    /// AR 세션을 재개하고 좌표계를 리셋합니다
    func resumeARSession() {
        guard let arView = arView else { return }
        
        print("▶️ AR 세션 재개 중...")
        
        // 좌표계 참조점 리셋 (pause/resume으로 인한 원점 변화 대응)
        resetARSessionReference()
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        
        print("✅ AR 세션 재개 완료 - 새로운 좌표계로 설정")
    }
    
    // MARK: - Placement Logic
    func placeTemporaryObject(
        flower: ARFlower,
        statusUpdate: @escaping (String) -> Void
    ) {
        // 기존 꽃이 있다면 제거 (새로운 꽃 선택 시)
        if let arView = arView, let existingFlower = currentFlowerAnchor {
            arView.scene.removeAnchor(existingFlower)
            currentFlowerAnchor = nil
        }
        
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
                    self?.createPlacementAnchor() // 앵커 생성
                    self?.onPlacementStateChanged?(
                        self?.placementState.status ?? .idle
                    )
                    statusUpdate("🔴 여기에 \(flower.name)를 심을까요?")
                }
            )
            .store(in: &cancellables)
    }
    
    private func addLightingToFlower(_ flowerEntity: ModelEntity) {
        // 🌞 방향성 조명: 햇빛 역할
        let directionalLight = DirectionalLight()
        directionalLight.light.intensity = 10000  // 더 강하게
        directionalLight.light.color = UIColor(red: 1.0, green: 0.96, blue: 0.85, alpha: 1.0) // 햇빛 느낌의 따뜻한 색

        // 햇빛이 약간 비스듬하게 비추는 느낌 (예: 남동쪽 방향에서)
        directionalLight.look(at: [0, -1, -0.5], from: [0, 1, 0.5], relativeTo: flowerEntity)

        // 🌤️ 부드러운 전체 조명: 그림자 어두움을 줄이기 위해 Ambient 느낌 추가
        let ambientLight = PointLight()
        ambientLight.light.intensity = 5000
        ambientLight.light.color = UIColor(red: 1.0, green: 0.97, blue: 0.9, alpha: 1.0)
        ambientLight.light.attenuationRadius = 2.0
        ambientLight.position = [0, 0.5, 0]

        // 조명들을 꽃에 추가
        flowerEntity.addChild(directionalLight)
        flowerEntity.addChild(ambientLight)
    }

    func confirmPlacement() {
        guard placementState.canConfirm,
              let arView = arView,
              let position = placementAnchor?.position,
              let currentFrame = arView.session.currentFrame else { return }
        
        // 인디케이터 위치에 꽃 생성
        if let entity = placementState.entity {
            let flowerAnchor = AnchorEntity(world: position)
            let flowerClone = entity.clone(recursive: true)
            
            // 🌸 카메라를 향하도록 꽃 회전 설정
            let cameraPosition = extractPositionFromTransform(currentFrame.camera.transform)
            let flowerPosition = position
            
            // 🌸 꽃 크기 조정
            let distanceVector = cameraPosition - flowerPosition
            let distance = simd_length(distanceVector)
            let dynamicScale = max(0.3, min(0.5, 0.8 / distance)) //꽃 크기 조정 가능
            flowerClone.transform.scale = SIMD3<Float>(dynamicScale, dynamicScale, dynamicScale)
            
            // 꽃에서 카메라로의 방향 벡터 계산
            let directionToCamera = normalize(cameraPosition - flowerPosition)
            
            // Y축 회전만 적용 (꽃이 기울어지지 않고 수평면에서만 회전)
            let horizontalDirection = normalize(SIMD3<Float>(directionToCamera.x, 0, directionToCamera.z))
            
            // 기본 앞 방향 (0, 0, -1)에서 목표 방향으로의 회전 계산
            let defaultForward = SIMD3<Float>(0, 0, -1)
            let angle = atan2(horizontalDirection.x, -horizontalDirection.z)
            
            // Y축 회전만 적용 (수평 회전만)
            let rotation = simd_quatf(angle: angle, axis: SIMD3<Float>(0, 1, 0))
            
            // 꽃 엔티티에 회전 적용
            flowerClone.transform.rotation = rotation
            addLightingToFlower(flowerClone)
            
            flowerAnchor.addChild(flowerClone)
            arView.scene.addAnchor(flowerAnchor)
            
            // 현재 꽃 앵커 추적 (재배치 시 제거용)
            self.currentFlowerAnchor = flowerAnchor
            
            // 배치된 좌표 정보 로그 출력
            logPlacementCoordinates(arPosition: position)
            
            print("🌸 꽃이 카메라를 향하도록 회전 적용: \(String(format: "%.1f", angle * 180 / Float.pi))도")
            print("🌸 꽃 크기 동적 조정: \(String(format: "%.1f", dynamicScale * 100))% (거리: \(String(format: "%.2f", distance))m - 멀어질수록 작아짐)")
        }
        
        placementState.confirm()
        removePlacementAnchor() // 앵커 제거
        onPlacementStateChanged?(placementState.status)
    }
    
    /// 현재 배치된 위치의 GPS 좌표를 반환합니다.
    /// - Returns: 배치된 위치의 GPS 좌표, 배치되지 않았거나 변환 실패 시 nil
    func getCurrentPlacementCoordinate() -> CLLocationCoordinate2D? {
        print("🚀 getCurrentPlacementCoordinate() 시작")
        
        guard let position = placementAnchor?.position else {
            print("⚠️ placementAnchor가 없음")
            return nil
        }
        
        print("🚀 placementAnchor 존재: [\(String(format: "%.3f", position.x)), \(String(format: "%.3f", position.y)), \(String(format: "%.3f", position.z))]")
        
        // convertARPositionToGeographic 호출 전 필수 데이터 확인
        print("🚀 arSessionStartLocation: \(arSessionStartLocation != nil ? "존재" : "nil")")
        print("🚀 arSessionStartHeading: \(arSessionStartHeading != nil ? "존재" : "nil")")
        
        if let startLoc = arSessionStartLocation {
            print("🚀 시작 위치: (\(String(format: "%.6f", startLoc.coordinate.latitude)), \(String(format: "%.6f", startLoc.coordinate.longitude)))")
        }
        
        if let startHeading = arSessionStartHeading {
            print("🚀 시작 방향: \(String(format: "%.1f", startHeading.trueHeading))°")
        }
        
        let coordinate = convertARPositionToGeographic(arPosition: position)
        if let coord = coordinate {
            print("✅ 현재 배치 좌표: (\(String(format: "%.6f", coord.latitude)), \(String(format: "%.6f", coord.longitude)))")
        } else {
            print("❌ GPS 좌표 변환 실패")
        }
        
        return coordinate
    }
    
    
    
    func startRepositioning() {
        guard placementState.status == .confirmed else { return }
        
        // 기존 꽃 제거
        if let arView = arView, let existingFlower = currentFlowerAnchor {
            arView.scene.removeAnchor(existingFlower)
            currentFlowerAnchor = nil
        }
        
        if let arView = arView {
            placementState.startRepositioning(in: arView)
        }
        createPlacementAnchor() // 재배치 시 새로운 인디케이터 생성
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
            return
        }
        
        // 현재 사용자 위치 및 헤딩 업데이트
        self.currentUserLocation = userLocation
        self.currentUserHeading = userHeading
        
        // 실시간 헤딩 정보를 UI에 전달
        let currentHeading = userHeading.trueHeading
        let directionString = getDirectionStringFromHeading(currentHeading)
        onHeadingUpdated?(currentHeading, directionString)
        
        // AR 세션 시작 위치와 헤딩이 없다면 현재 위치/헤딩으로 설정
        if arSessionStartLocation == nil {
            arSessionStartLocation = userLocation
            arSessionStartHeading = userHeading
        }
        
        
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
                    continue
                }
                
                let arPosition = transformUseCase.transform(
                    userCoordinate: userLocation.coordinate,
                    userHeading: userHeading,
                    targetCoordinate: recordCoordinate
                )
                
                // 추가 안전 검사
                let distance = length(arPosition)
                if distance > 100.0 || distance < 0.1 || arPosition.x.isNaN
                    || arPosition.z.isNaN
                {
                    continue
                }
                
                createMarkerForRecord(record, at: arPosition, arView: arView)
            }
        }
    }
    
    private func removeObsoleteMarkers(currentRecords: [ARRecordModel]) {
        let currentRecordIds = Set(currentRecords.map { $0.id })
        
        for (recordId, marker) in recordMarkers {
            if !currentRecordIds.contains(recordId) {
                marker.parent?.removeFromParent()
                recordMarkers.removeValue(forKey: recordId)
            }
        }
    }
    
    private func createMarkerForRecord(
        _ record: ARRecordModel,
        at position: SIMD3<Float>,
        arView: ARView
    ) {
        let marker = ARMarker(record: record)
        marker.generateCollisionShapes(recursive: true)
        let anchor = AnchorEntity(world: position)
        
        // 디버깅을 위한 이름 설정
        marker.name = "ARMarker_\(record.id)"
        anchor.name = "Anchor_\(record.id)"
        
        anchor.addChild(marker)
        arView.scene.addAnchor(anchor)
        recordMarkers[record.id] = marker
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
                return Entity.loadModelAsync(named: modelName)
                    .eraseToAnyPublisher()
            }
            .catch { error -> AnyPublisher<ModelEntity, Error> in
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
    
    nonisolated func session(_ session: ARSession, didFailWithError error: Error) {
        Task { @MainActor in
            print("🚨 AR 세션 실패: \(error.localizedDescription)")
            resetARSessionReference()
        }
    }
    
    
    
    nonisolated func sessionWasInterrupted(_ session: ARSession) {
        Task { @MainActor in
            print("⚠️ AR 세션 중단됨 - 좌표계 참조점 초기화")
            resetARSessionReference()
        }
    }
    
    nonisolated func sessionInterruptionEnded(_ session: ARSession) {
        Task { @MainActor in
            print("✅ AR 세션 재개됨 - 새로운 좌표계로 재설정 예정")
            // 세션이 재개되면 다음 위치 업데이트 시 새로운 참조점이 설정됩니다
        }
    }
    
    nonisolated func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        Task { @MainActor in
            switch camera.trackingState {
            case .limited(.relocalizing):
                print("⚠️ AR 추적 상태: 재위치화 중 - 좌표계 참조점 초기화")
                resetARSessionReference()
            case .notAvailable:
                print("❌ AR 추적 불가능 - 좌표계 참조점 초기화")
                resetARSessionReference()
            case .normal:
                print("✅ AR 추적 정상")
            case .limited(let reason):
                print("⚠️ AR 추적 제한됨: \(reason)")
                // 일시적인 제한은 참조점을 유지
            @unknown default:
                print("🤷‍♂️ 알 수 없는 AR 추적 상태")
            }
        }
    }
    
    /// AR 세션 참조점을 초기화합니다
    private func resetARSessionReference() {
        arSessionStartLocation = nil
        arSessionStartHeading = nil
        print("🔄 AR 세션 참조점 초기화 완료")
    }
    // MARK: - Scene Update Subscription
    private func setupSceneUpdateSubscription(arView: ARView) {
        arView.scene.subscribe(to: SceneEvents.Update.self) { [weak self] event in
            guard let self = self else { return }
            
            // 배치 모드가 아니면 업데이트 중단
            guard self.placementState.status == .placing,
                  let anchor = self.placementAnchor else {
                return
            }
            
            // 💡 핵심 개선: 더 적극적인 위치 업데이트
            if let newPosition = self.getPlacementPositionFromRaycast() {
                // raycast 성공 시 즉시 업데이트
                anchor.position = newPosition
            } else {
                // raycast 실패 시에도 fallback으로 즉시 업데이트
                if let fallbackPosition = self.getFallbackPlacementPosition() {
                    anchor.position = fallbackPosition
                } else {
                    // 최후의 수단: 카메라 앞 고정 거리에 배치
                    if let emergencyPosition = self.getEmergencyPlacementPosition() {
                        anchor.position = emergencyPosition
                    }
                }
            }
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Placement Position Methods (수정된 버전)
    private func getPlacementPositionFromRaycast() -> SIMD3<Float>? {
        guard let arView = arView else {
            raycastStatus = .failed
            return nil
        }
        
        // 화면 중앙 좌표 정확히 계산
        let screenCenter = CGPoint(
            x: arView.bounds.midX,
            y: arView.bounds.midY
        )
        
        // 🎯 1단계: 기존 평면 지오메트리로 raycast
        let existingPlaneResults = arView.raycast(
            from: screenCenter,
            allowing: .existingPlaneGeometry,
            alignment: .horizontal
        )
        
        if let result = existingPlaneResults.first {
            let position = extractPositionFromTransform(result.worldTransform)
            let distance = length(position - getCameraPosition())
            raycastStatus = .success(distance: distance)
            lastRaycastDistance = distance
            return position
        }
        
        // 🎯 2단계: 추정 평면으로 raycast
        let estimatedResults = arView.raycast(
            from: screenCenter,
            allowing: .estimatedPlane,
            alignment: .horizontal
        )
        
        if let result = estimatedResults.first {
            let position = extractPositionFromTransform(result.worldTransform)
            let distance = length(position - getCameraPosition())
            raycastStatus = .fallback(distance: distance)
            lastRaycastDistance = distance
            return position
        }
        
        // 🎯 3단계: 더 관대한 raycast (수직 평면도 포함)
        let anyPlaneResults = arView.raycast(
            from: screenCenter,
            allowing: .estimatedPlane,
            alignment: .any
        )
        
        if let result = anyPlaneResults.first {
            let position = extractPositionFromTransform(result.worldTransform)
            let distance = length(position - getCameraPosition())
            raycastStatus = .fallback(distance: distance)
            lastRaycastDistance = distance
            return position
        }
        
        raycastStatus = .failed
        return nil
    }
    
    private func getFallbackPlacementPosition() -> SIMD3<Float>? {
        guard let arView = arView,
              let currentFrame = arView.session.currentFrame else {
            raycastStatus = .failed
            return nil
        }
        
        let cameraTransform = currentFrame.camera.transform
        let cameraPosition = extractPositionFromTransform(cameraTransform)
        let forwardDirection = extractForwardFromTransform(cameraTransform)
        
        // 🎯 더 똑똑한 fallback: 카메라 각도에 따라 거리 조절
        let pitch = asin(forwardDirection.y) * 180.0 / Float.pi
        
        // 카메라가 아래를 향할수록 가까이, 위를 향할수록 멀리
        let basePlacementDistance: Float = 1.5
        let distanceMultiplier: Float
        
        switch pitch {
        case ..<(-45): // 많이 아래를 향함
            distanceMultiplier = 0.7
        case (-45)..<(-15): // 약간 아래를 향함
            distanceMultiplier = 0.85
        case (-15)...(15): // 거의 수평
            distanceMultiplier = 1.0
        case 15..<45: // 약간 위를 향함
            distanceMultiplier = 1.3
        default: // 많이 위를 향함
            distanceMultiplier = 1.8
        }
        
        let placementDistance = basePlacementDistance * distanceMultiplier
        
        // 수평 방향으로만 이동
        let horizontalForward = normalize(SIMD3<Float>(forwardDirection.x, 0, forwardDirection.z))
        let targetPosition = cameraPosition + (horizontalForward * placementDistance)
        
        // Y 위치는 카메라 높이에서 적절히 조절
        let adjustedPosition = SIMD3<Float>(
            targetPosition.x,
            cameraPosition.y - 0.3, // 30cm 아래
            targetPosition.z
        )
        
        raycastStatus = .fallback(distance: placementDistance)
        lastRaycastDistance = placementDistance
        
        return adjustedPosition
    }
    private func getEmergencyPlacementPosition() -> SIMD3<Float>? {
        guard let arView = arView,
              let currentFrame = arView.session.currentFrame else {
            return nil
        }
        
        let cameraTransform = currentFrame.camera.transform
        let cameraPosition = extractPositionFromTransform(cameraTransform)
        let forwardDirection = extractForwardFromTransform(cameraTransform)
        
        // 카메라 정면 1미터에 무조건 배치 (절대 실패하지 않음)
        let emergencyDistance: Float = 1.0
        let horizontalForward = normalize(SIMD3<Float>(forwardDirection.x, 0, forwardDirection.z))
        
        let emergencyPosition = SIMD3<Float>(
            cameraPosition.x + horizontalForward.x * emergencyDistance,
            cameraPosition.y - 0.5, // 50cm 아래
            cameraPosition.z + horizontalForward.z * emergencyDistance
        )
        
        raycastStatus = .fallback(distance: emergencyDistance)
        lastRaycastDistance = emergencyDistance
        
        print("🚨 Emergency placement at: [\(String(format: "%.3f", emergencyPosition.x)), \(String(format: "%.3f", emergencyPosition.y)), \(String(format: "%.3f", emergencyPosition.z))]")
        
        return emergencyPosition
    }
    private func extractPositionFromTransform(_ transform: simd_float4x4) -> SIMD3<Float> {
        return SIMD3<Float>(
            transform.columns.3.x,
            transform.columns.3.y,
            transform.columns.3.z
        )
    }

    private func extractForwardFromTransform(_ transform: simd_float4x4) -> SIMD3<Float> {
        return -SIMD3<Float>(
            transform.columns.2.x,
            transform.columns.2.y,
            transform.columns.2.z
        )
    }

    
    
    // MARK: - Placement Anchor Creation (수정된 버전)
    private func createPlacementAnchor() {
        guard let arView = arView else { return }
        
        // 기존 인디케이터 제거
        removePlacementAnchor()
        
        // 💡 더 적극적인 초기 위치 결정
        var position: SIMD3<Float>?
        
        // 1차 시도: raycast
        position = getPlacementPositionFromRaycast()
        
        // 2차 시도: fallback
        if position == nil {
            position = getFallbackPlacementPosition()
        }
        
        // 3차 시도: emergency (절대 실패하지 않음)
        if position == nil {
            position = getEmergencyPlacementPosition()
        }
        
        guard let finalPosition = position else {
            print("❌ 모든 배치 방법 실패")
            return
        }
        
        // 🎭 펄스 애니메이션 추가
        let scaleUp = Transform(scale: SIMD3<Float>(1.2, 1.2, 1.2), rotation: simd_quatf(), translation: SIMD3<Float>(0, 0, 0))
        let scaleDown = Transform(scale: SIMD3<Float>(0.8, 0.8, 0.8), rotation: simd_quatf(), translation: SIMD3<Float>(0, 0, 0))
        
        let scaleAnimation = FromToByAnimation(
            name: "pulse",
            from: scaleDown,
            to: scaleUp,
            duration: 0.8,
            timing: .easeInOut,
            isAdditive: false
        )
        
        let animationResource = try? AnimationResource.generate(with: scaleAnimation)
       
        
        // 그림자 효과
        let shadowMesh = MeshResource.generatePlane(width: 0.25, depth: 0.25,cornerRadius: 50)
       
  

        var shadowMaterial = UnlitMaterial()
        shadowMaterial.baseColor = MaterialColorParameter.color(UIColor.red.withAlphaComponent(0.3))
        
     
   
        let shadow = ModelEntity(mesh: shadowMesh, materials: [shadowMaterial])
        shadow.position.y = -0.12
        
        let dashedCircle = makeDashedCircle(
            radius: 0.125,              // 바깥 원의 반지름
            dotCount: 24,               // 점 개수 (숫자가 작을수록 간격 넓음)
            dotSize: 0.005,             // 점 하나의 크기 (반지름)
            color: UIColor.white.withAlphaComponent(0.8) // 점 색상 및 투명도
        )
        dashedCircle.position.y = -0.12
        
        if let resource = animationResource {
            shadow.playAnimation(resource.repeat())
            dashedCircle.playAnimation(resource.repeat())
        }
        
        // 앵커 생성 및 설정
        let indicatorAnchor = AnchorEntity(world: finalPosition)
        indicatorAnchor.addChild(dashedCircle)
        indicatorAnchor.addChild(shadow)
        arView.scene.addAnchor(indicatorAnchor)
        
        self.placementAnchor = indicatorAnchor
        
        print("✅ 개선된 인디케이터 생성: [\(String(format: "%.3f", finalPosition.x)), \(String(format: "%.3f", finalPosition.y)), \(String(format: "%.3f", finalPosition.z))]")
    }
    
    func makeDashedCircle(radius: Float, dotCount: Int, dotSize: Float, color: UIColor) -> Entity {
        let parent = Entity()

        for i in 0..<dotCount {
            let angle = (Float(i) / Float(dotCount)) * 2 * Float.pi
            let x = cos(angle) * radius
            let z = sin(angle) * radius

            let dotMesh = MeshResource.generateSphere(radius: dotSize)
            var dotMaterial = UnlitMaterial()
            dotMaterial.baseColor = .color(color)

            let dotEntity = ModelEntity(mesh: dotMesh, materials: [dotMaterial])
            dotEntity.position = [x, 0, z]

            parent.addChild(dotEntity)
        }

        return parent
    }
    
    
    private func removePlacementAnchor() {
        guard let arView = arView,
              let anchor = placementAnchor else { return }
        
        arView.scene.removeAnchor(anchor)
        self.placementAnchor = nil
        self.isRaycastActive = false // raycast 비활성화
        raycastStatus = .idle
        
        print("🗑️ 인디케이터 제거 완료")
    }
    
    func removePlacementObject() {
        if let arView = arView {
            placementState.removeFrom(arView: arView)
        }
        removePlacementAnchor()
        onPlacementStateChanged?(placementState.status)
    }
    
    // 카메라 위치 헬퍼 메서드 추가
    private func getCameraPosition() -> SIMD3<Float> {
        guard let arView = arView,
              let currentFrame = arView.session.currentFrame else {
            return SIMD3<Float>(0, 0, 0)
        }
        
        let cameraTransform = currentFrame.camera.transform
        return SIMD3<Float>(
            cameraTransform.columns.3.x,
            cameraTransform.columns.3.y,
            cameraTransform.columns.3.z
        )
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
            handleMarkerTap(tappedMarker)
        } else {
            handleEmptySpaceTap()
        }
    }
    
    private func handleMarkerTap(_ marker: ARMarker) {
        if marker !== selectedMarker {
            // 이전 마커의 포커스 해제
            if let prevMarker = selectedMarker {
                prevMarker.setFocus(isFocused: false)
            }
            
            // 새 마커에 포커스
            marker.setFocus(isFocused: true)
            
            // 카메라 매니저에 포커스 요청
            cameraManager?.focus(on: marker)
            
            // 콜백 호출
            onRecordTapped?(marker.record)
            
            // 선택된 마커 업데이트
            selectedMarker = marker
        } else {
            // 같은 마커를 다시 탭한 경우 선택 해제
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
    
    // MARK: - Coordinate Conversion
    private func convertARPositionToGeographic(arPosition: SIMD3<Float>) -> CLLocationCoordinate2D? {
        print("🎯 convertARPositionToGeographic() 시작")
        print("🎯 입력 AR 위치: [\(String(format: "%.3f", arPosition.x)), \(String(format: "%.3f", arPosition.y)), \(String(format: "%.3f", arPosition.z))]")
        
        guard let startLocation = arSessionStartLocation,
              let startHeading = arSessionStartHeading else {
            print("❌ arSessionStartLocation 또는 arSessionStartHeading이 nil")
            print("🎯 arSessionStartLocation: \(arSessionStartLocation?.description ?? "nil")")
            print("🎯 arSessionStartHeading: \(arSessionStartHeading?.description ?? "nil")")
            return nil
        }
        
        print("🎯 시작 위치: (\(String(format: "%.6f", startLocation.coordinate.latitude)), \(String(format: "%.6f", startLocation.coordinate.longitude)))")
        print("🎯 시작 방향: \(String(format: "%.1f", startHeading.trueHeading))°")
        
        // 더 정확한 지구 측지학적 상수들
        let earthRadiusM = 6378137.0 // WGS84 지구 반지름 (미터)
        let degToRad = Double.pi / 180.0
        let radToDeg = 180.0 / Double.pi
        
        // AR 세션 시작 시 사용자가 바라보던 방향 (자북 기준)
        let sessionStartBearing = startHeading.trueHeading
        let bearingRadians = sessionStartBearing * degToRad
        
        // AR 좌표를 지리적 방향으로 정확히 회전 변환
        // AR 좌표계: X(오른쪽), Y(위), Z(뒤) → 지리적: X(동), Y(북)
        let arForward = Double(-arPosition.z)  // AR에서 앞쪽 (사용자가 바라보는 방향)
        let arRight = Double(arPosition.x)     // AR에서 오른쪽
        
        print("🎯 AR 변환: forward=\(String(format: "%.3f", arForward)), right=\(String(format: "%.3f", arRight))")
        
        // 회전 변환: 세션 시작 방향을 기준으로 실제 지리적 방향에 정렬
        let eastOffset = arRight * cos(bearingRadians) + arForward * sin(bearingRadians)
        let northOffset = -arRight * sin(bearingRadians) + arForward * cos(bearingRadians)
        
        print("🎯 지리적 오프셋: east=\(String(format: "%.3f", eastOffset)), north=\(String(format: "%.3f", northOffset))")
        
        // 시작 위치의 위도 (라디안)
        let startLatRad = startLocation.coordinate.latitude * degToRad
        
        // 정확한 지리적 좌표 변환
        // 위도 변화: 북쪽 방향 오프셋을 위도 변화로 변환
        let deltaLatitude = (northOffset / earthRadiusM) * radToDeg
        
        // 경도 변화: 동쪽 방향 오프셋을 경도 변화로 변환 (위도에 따른 보정 적용)
        let deltaLongitude = (eastOffset / (earthRadiusM * cos(startLatRad))) * radToDeg
        
        let newLatitude = startLocation.coordinate.latitude + deltaLatitude
        let newLongitude = startLocation.coordinate.longitude + deltaLongitude
        
        print("🎯 델타 계산: deltaLat=\(String(format: "%.8f", deltaLatitude)), deltaLon=\(String(format: "%.8f", deltaLongitude))")
        print("🎯 최종 좌표: (\(String(format: "%.6f", newLatitude)), \(String(format: "%.6f", newLongitude)))")
        
        return CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
    }
    
    private func logPlacementCoordinates(arPosition: SIMD3<Float>) {
        guard let placementCoordinate = convertARPositionToGeographic(arPosition: arPosition),
              let currentLocation = currentUserLocation,
              let currentHeading = currentUserHeading else {
            return
        }
        
        print("🌸 ===== 꽃 배치 좌표 정보 =====")
        print("📍 AR 좌표: [\(String(format: "%.3f", arPosition.x)), \(String(format: "%.3f", arPosition.y)), \(String(format: "%.3f", arPosition.z))]")
        print("🧭 현재 헤딩: \(String(format: "%.1f", currentHeading.trueHeading))° (자북 기준)")
        print("🌍 배치된 곳: (\(String(format: "%.6f", placementCoordinate.latitude)), \(String(format: "%.6f", placementCoordinate.longitude)))")
        print("📱 현재 내 위치: (\(String(format: "%.6f", currentLocation.coordinate.latitude)), \(String(format: "%.6f", currentLocation.coordinate.longitude)))")
        
        // 거리 계산
        let placementLocation = CLLocation(latitude: placementCoordinate.latitude, longitude: placementCoordinate.longitude)
        let distance = currentLocation.distance(from: placementLocation)
        
        print("📏 거리: \(String(format: "%.2f", distance))m")
        print("🧭 방향: \(getDirectionString(from: currentLocation.coordinate, to: placementCoordinate))")
        
        // AR 좌표로부터의 직선 거리 비교
        let arDistance = sqrt(arPosition.x * arPosition.x + arPosition.z * arPosition.z)
        print("📐 AR 직선거리: \(String(format: "%.2f", arDistance))m (참고용)")
        print("===============================")
    }
    
    private func getDirectionString(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> String {
        // 정확한 bearing 계산 (측지학적 방법)
        let lat1Rad = from.latitude * .pi / 180.0
        let lat2Rad = to.latitude * .pi / 180.0
        let deltaLonRad = (to.longitude - from.longitude) * .pi / 180.0
        
        let y = sin(deltaLonRad) * cos(lat2Rad)
        let x = cos(lat1Rad) * sin(lat2Rad) - sin(lat1Rad) * cos(lat2Rad) * cos(deltaLonRad)
        
        let bearingRad = atan2(y, x)
        let bearingDeg = bearingRad * 180.0 / .pi
        let normalizedBearing = bearingDeg < 0 ? bearingDeg + 360 : bearingDeg
        
        let directionString: String
        switch normalizedBearing {
        case 0..<22.5, 337.5...360: directionString = "북쪽"
        case 22.5..<67.5: directionString = "북동쪽"
        case 67.5..<112.5: directionString = "동쪽"
        case 112.5..<157.5: directionString = "남동쪽"
        case 157.5..<202.5: directionString = "남쪽"
        case 202.5..<247.5: directionString = "남서쪽"
        case 247.5..<292.5: directionString = "서쪽"
        case 292.5..<337.5: directionString = "북서쪽"
        default: directionString = "알 수 없음"
        }
        
        return "\(directionString) (\(String(format: "%.1f", normalizedBearing))°)"
    }
    
    // MARK: - Real-time Heading
    private func getDirectionStringFromHeading(_ heading: Double) -> String {
        let normalizedHeading = heading < 0 ? heading + 360 : heading
        
        switch normalizedHeading {
        case 0..<22.5, 337.5...360: return "북쪽"
        case 22.5..<67.5: return "북동쪽"
        case 67.5..<112.5: return "동쪽"
        case 112.5..<157.5: return "남동쪽"
        case 157.5..<202.5: return "남쪽"
        case 202.5..<247.5: return "남서쪽"
        case 247.5..<292.5: return "서쪽"
        case 292.5..<337.5: return "북서쪽"
        default: return "알 수 없음"
        }
    }
    // MARK: - ARSessionDelegate (수정)
    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
        Task { @MainActor in
            // 카메라 방향 업데이트
            let cameraTransform = frame.camera.transform
            self.updateCameraOrientation(from: cameraTransform)
            
            // 💡 추가: 카메라가 빠르게 움직일 때 즉시 인디케이터 업데이트
            if self.placementState.status == .placing,
               let anchor = self.placementAnchor {
                
                // 카메라 움직임 감지 (이전 프레임과 비교)
                let currentCameraPos = self.extractPositionFromTransform(cameraTransform)
                
                // 빠른 움직임 감지되면 즉시 업데이트
                if self.shouldForceUpdate(currentCameraPosition: currentCameraPos) {
                    if let newPosition = self.getPlacementPositionFromRaycast() {
                        anchor.position = newPosition
                    } else if let fallbackPosition = self.getFallbackPlacementPosition() {
                        anchor.position = fallbackPosition
                    }
                }
            }
        }
    }
    private func updateCameraOrientation(from transform: simd_float4x4) {
        // 카메라의 forward 벡터 추출 (카메라가 바라보는 방향)
        let forward = SIMD3<Float>(
            -transform.columns.2.x,
             -transform.columns.2.y,
             -transform.columns.2.z
        )
        
        // Pitch 계산 (상하 각도)
        let pitch = asin(forward.y) * 180.0 / Float.pi
        let pitchDouble = Double(pitch)
        
        // 방향 문자열 생성
        let pitchDirection = getPitchDirectionString(from: pitchDouble)
        
        // UI 업데이트
        onCameraOrientationUpdated?(pitchDouble, pitchDirection)
    }
    
    // Pitch 방향 문자열 생성 메서드 (추가)
    private func getPitchDirectionString(from pitch: Double) -> String {
        switch pitch {
        case 60...: return "하늘"
        case 30..<60: return "위쪽"
        case 10..<30: return "약간 위"
        case -10..<10: return "수평"
        case -30..<(-10): return "약간 아래"
        case -60..<(-30): return "아래쪽"
        case ..<(-60): return "바닥"
        default: return "수평"
        }
    }
}

// MARK: - ARCameraManagerDelegate
@available(iOS 18.0, *)
extension ARSceneManager: ARCameraManagerDelegate {
    func cameraManagerDidUpdateFocusState(isFocused: Bool) {
        // 포커스 상태 변화를 상위 레이어에 전달
        onFocusStateChanged?(isFocused)
    }
}

extension SIMD4<Float> {
    /// SIMD4<Float>의 x, y, z 요소를 사용하여 SIMD3<Float>를 반환합니다.
    var xyz: SIMD3<Float> {
        return SIMD3<Float>(x, y, z)
    }
}
