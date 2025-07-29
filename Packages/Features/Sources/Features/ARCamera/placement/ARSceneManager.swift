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

    // MARK: - Callbacks
    var onRecordTapped: ((ARRecordModel) -> Void)?
    var onPlacementStateChanged: ((ARPlacementState.Status) -> Void)?
    var onFocusStateChanged: ((Bool) -> Void)?

    // MARK: - Setup
    func setup(arView: ARView) {
        print("🔧 ARSceneManager setup 시작")
        self.arView = arView
        self.cameraManager = ARCameraManager(arView: arView)

        // 델리게이트 설정 추가
        self.cameraManager?.delegate = self

        arView.session.delegate = self
        setupGestures(on: arView)

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)

        print("🔧 ARSceneManager setup 완료")
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
                    self?.onPlacementStateChanged?(
                        self?.placementState.status ?? .idle
                    )
                    statusUpdate("꽃을 배치할 위치를 정해주세요.")
                }
            )
            .store(in: &cancellables)
    }

    func confirmPlacement() {
        guard placementState.canConfirm else { return }

        placementState.confirm()

        if let arView = arView,
            let anchor = placementState.createPermanentAnchor()
        {
            arView.scene.addAnchor(anchor)
        }

        onPlacementStateChanged?(placementState.status)
    }

    func removePlacementObject() {
        if let arView = arView {
            placementState.removeFrom(arView: arView)
        }
        onPlacementStateChanged?(placementState.status)
    }

    func startRepositioning() {
        guard placementState.status == .confirmed else { return }

        if let arView = arView {
            placementState.startRepositioning(in: arView)
        }
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

//        print("🔄 업데이트할 레코드 수: \(records.count)")

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
                return Entity.loadModelAsync(named: modelName)
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
            updatePlacementPosition(frame: frame)
        }
    }

    private func updatePlacementPosition(frame: ARFrame) {
        guard let arView = arView,
            placementState.status == .placing,
            let entityToPlace = placementState.entity
        else { return }

        let centerOfScreen = arView.center
        let raycastResults = arView.raycast(
            from: centerOfScreen,
            allowing: .estimatedPlane,
            alignment: .horizontal
        )

        guard let firstResult = raycastResults.first else {
            entityToPlace.isEnabled = false
            return
        }

        let targetPosition = SIMD3<Float>(
            firstResult.worldTransform.columns.3.x,
            firstResult.worldTransform.columns.3.y,
            firstResult.worldTransform.columns.3.z
        )

        let transform = calculatePlacementTransform(
            position: targetPosition,
            cameraTransform: frame.camera.transform
        )

        placementState.updatePosition(transform: transform, in: arView)

        if !entityToPlace.isEnabled {
            entityToPlace.isEnabled = true
        }
    }

    private func calculatePlacementTransform(
        position: SIMD3<Float>,
        cameraTransform: float4x4
    ) -> float4x4 {
        let forwardVector = -SIMD3<Float>(
            cameraTransform.columns.2.x,
            cameraTransform.columns.2.y,
            cameraTransform.columns.2.z
        )

        let horizontalForward = normalize(
            SIMD3<Float>(forwardVector.x, 0, forwardVector.z)
        )

        guard
            length(SIMD2<Float>(horizontalForward.x, horizontalForward.z)) > 0.1
        else {
            return float4x4(translation: position)
        }

        let zAxis = -horizontalForward
        let xAxis = normalize(cross(SIMD3<Float>(0, 1, 0), zAxis))
        let yAxis = cross(zAxis, xAxis)

        return float4x4(
            SIMD4(xAxis, 0),
            SIMD4(yAxis, 0),
            SIMD4(zAxis, 0),
            SIMD4(position, 1)
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
        print("🖱️ 탭 제스처 설정 완료")
    }

    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        guard let arView = arView else {
            print("❌ ARView 없음")
            return
        }

        let location = sender.location(in: arView)
        print("🖱️ 탭 위치: \(location)")

        // 1. 먼저 충돌 기반 엔티티 검색
        let hitEntities = arView.entities(at: location)
        print("🎯 충돌 감지된 엔티티 수: \(hitEntities.count)")

        for entity in hitEntities {
            print("🔍 감지된 엔티티: \(entity.name), 타입: \(type(of: entity))")
        }

        // 2. ARMarker 찾기
        let tappedMarker = hitEntities.compactMap { findARMarker(in: $0) }.first

        // 3. 충돌 감지 실패시 레이캐스트 시도
        if tappedMarker == nil {
            print("🔍 충돌 감지 실패, 레이캐스트 시도")
            let raycastResults = arView.raycast(
                from: location,
                allowing: .estimatedPlane,
                alignment: .any
            )

            for result in raycastResults {
                if let anchor = result.anchor,
                    let anchorEntity = arView.scene.findEntity(
                        named: anchor.identifier.uuidString
                    )
                {
                    if let marker = findARMarker(in: anchorEntity) {
                        print("🎯 레이캐스트로 마커 발견: \(marker.record.id)")
                        handleMarkerTap(marker)
                        return
                    }
                }
            }

            // 4. 최후의 수단: 거리 기반 검색
            print("🔍 거리 기반 마커 검색 시도")
            if let nearestMarker = findNearestMarkerToScreenPoint(
                location,
                in: arView
            ) {
                print("🎯 가장 가까운 마커 발견: \(nearestMarker.record.id)")
                handleMarkerTap(nearestMarker)
                return
            }
        } else {
            print("🎯 충돌 감지로 마커 발견: \(tappedMarker!.record.id)")
            handleMarkerTap(tappedMarker!)
        }

        // 마커를 찾지 못한 경우
        print("❌ 마커를 찾을 수 없음")
        handleEmptySpaceTap()
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
}

// MARK: - ARCameraManagerDelegate
extension ARSceneManager: ARCameraManagerDelegate {
    func cameraManagerDidUpdateFocusState(isFocused: Bool) {
        // 포커스 상태 변화를 상위 레이어에 전달
        onFocusStateChanged?(isFocused)

        print("📷 Camera focus state changed: \(isFocused)")
    }
}
