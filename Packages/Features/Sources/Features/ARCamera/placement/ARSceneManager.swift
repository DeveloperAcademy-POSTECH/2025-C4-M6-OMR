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
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Placement Management
    private var placementState = ARPlacementState()
    var placementEntity: ModelEntity? { placementState.entity }
    
    // MARK: - Scene Management
    private var recordMarkers: [UUID: ARMarker] = [:]
    
    // MARK: - Callbacks
    var onRecordTapped: ((ARRecordModel) -> Void)?
    var onPlacementStateChanged: ((ARPlacementState.Status) -> Void)?

    // MARK: - Setup
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
                    self?.onPlacementStateChanged?(self?.placementState.status ?? .idle)
                    statusUpdate("꽃을 배치할 위치를 정해주세요.")
                }
            )
            .store(in: &cancellables)
    }
    
    func confirmPlacement() {
        guard placementState.canConfirm else { return }
        
        placementState.confirm()
        
        if let arView = arView, let anchor = placementState.createPermanentAnchor() {
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
        guard let arView = arView else { return }
        
        // 기존 마커들 중 더 이상 필요 없는 것들 제거
        removeObsoleteMarkers(currentRecords: records)
        
        // 새로운 레코드들에 대해 마커 생성
        for record in records {
            if recordMarkers[record.id] == nil {
                createMarkerForRecord(record, userLocation: userLocation, userHeading: userHeading, transformUseCase: transformUseCase, arView: arView)
            }
        }
    }
    
    private func removeObsoleteMarkers(currentRecords: [ARRecordModel]) {
        let currentRecordIds = Set(currentRecords.map { $0.id })
        
        for (recordId, marker) in recordMarkers {
            if !currentRecordIds.contains(recordId) {
                marker.removeFromParent()
                recordMarkers.removeValue(forKey: recordId)
            }
        }
    }
    
    private func createMarkerForRecord(
        _ record: ARRecordModel,
        userLocation: CLLocation,
        userHeading: CLHeading,
        transformUseCase: TransformCoordinateUseCase,
        arView: ARView
    ) {
        let recordCoordinate = CLLocationCoordinate2D(
            latitude: record.coordinate.latitude,
            longitude: record.coordinate.longitude
        )
        
        let arPosition = transformUseCase.transform(
            userCoordinate: userLocation.coordinate,
            userHeading: userHeading,
            targetCoordinate: recordCoordinate
        )
        
        let marker = ARMarker(record: record)
        marker.transform.translation = arPosition
        
        let anchor = AnchorEntity(world: marker.transform.matrix)
        anchor.addChild(marker)
        arView.scene.addAnchor(anchor)
        
        recordMarkers[record.id] = marker
    }
    
    // MARK: - Model Loading
    private func loadModelWithFallback(modelName: String, flower: ARFlower) -> AnyPublisher<ModelEntity, Error> {
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
                    materials: [SimpleMaterial(color: .systemPink, isMetallic: false)]
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
              let entityToPlace = placementState.entity else { return }
        
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
        
        let horizontalForward = normalize(SIMD3<Float>(forwardVector.x, 0, forwardVector.z))
        
        guard length(SIMD2<Float>(horizontalForward.x, horizontalForward.z)) > 0.1 else {
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        guard let arView = arView else { return }
        
        let location = sender.location(in: arView)
        if let tappedEntity = arView.entity(at: location),
           let marker = findARMarker(in: tappedEntity) {
            onRecordTapped?(marker.record)
        }
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
