import SwiftUI
import ARKit
import RealityKit
import Combine
import CoreLocation
import Domain
import DesignSystem
import Dependencies

@MainActor
class ARCameraViewModel: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var viewData = ARCameraViewData()

    // MARK: - Private Properties
    private let arSceneManager = ARSceneManager()
    private var cancellables = Set<AnyCancellable>()
    
//    @Dependency(\.fetchMyRecordsUseCase) private var fetchMyRecordsUseCase
//    @Dependency(\.saveRecordUseCase) private var saveRecordUseCase
    private let transformUseCase = TransformCoordinateUseCase()
    
    private let locationManager = CLLocationManager()
    private var allRecords: [ARRecordModel] = []
    
    let flowerSelectionViewModel = FlowerSelectionViewModel()
    
    private let location: CLLocation


    // MARK: - Initialization
    init(location: CLLocation) {
        self.location = location
        super.init()
        setupFlowerSelectionCallback()
        setupARSceneManagerCallbacks()
    }
    
    private func setupFlowerSelectionCallback() {
        flowerSelectionViewModel.onFlowerSelected = { [weak self] flowerId in
            guard let self else { return }
            if let flower = self.flowerSelectionViewModel.flowers.first(where: { $0.id == flowerId }) {
                let arFlower = ARFlower(id: flower.id, name: flower.name, modelName: "test_flower")
                self.viewData.selectedFlower = arFlower
                self.arSceneManager.placeTemporaryObject(flower: arFlower) { [weak self] message in
                    print(message)
                    self?.viewData.statusMessage = message
                }
                self.viewData.isShowingFlowerSelectionSheet = false
            }
        }
    }

    private func setupARSceneManagerCallbacks() {
        arSceneManager.onRecordTapped = { [weak self] record in
            guard let self else { return }
            self.viewData.selectedRecord = record
            self.viewData.isShowingRecordDetailSheet = true
        }
    }
    
    // MARK: - Public Methods
    
    func setupARView(_ arView: ARView) {
        arSceneManager.setupARView(arView) // Delegate to manager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
    }
    
    func startARSession() {
        Task {
            await fetchAndPlaceRecords()
        }
    }
    
    // MARK: - Mode Switching & Placement
    
    func switchToPlacementMode() {
        viewData.cameraMode = .placement
        viewData.isPlacementConfirmed = false
        viewData.isShowingFlowerSelectionSheet = true
        viewData.statusMessage = "배치할 꽃을 선택하세요."
    }
    
    func switchToNormalMode() {
        viewData.cameraMode = .normal
        arSceneManager.removePlacementObject() // Delegate to manager
    }
    
    func confirmPlacement() {
        // Check if there's a placement entity in ARSceneManager
        guard arSceneManager.placementEntity != nil else {
            viewData.statusMessage = "배치할 객체가 없습니다."
            return
        }
        arSceneManager.confirmPlacement()
        viewData.isPlacementConfirmed = true
        viewData.statusMessage = "배치가 확정되었습니다. 저장 버튼을 눌러 기록을 저장하세요."
    }

    func cancelPlacement() {
        viewData.isPlacementConfirmed = false
        arSceneManager.removePlacementObject()
        viewData.isShowingFlowerSelectionSheet = true
        viewData.statusMessage = "배치를 취소했습니다. 다시 꽃을 선택하세요."
    }

    func repositionPlacement() {
        viewData.isPlacementConfirmed = false
        arSceneManager.startRepositioning()
        viewData.statusMessage = "꽃을 다시 배치하세요."
    }
    
    func saveRecord(title: String, description: String) {
        guard let selectedFlower = viewData.selectedFlower else {
            viewData.statusMessage = "저장에 필요한 정보가 부족합니다."
            return
        }
        guard let selectedRecord = viewData.selectedRecord else {
            viewData.statusMessage = "저장에 필요한 정보가 부족합니다."
            return
        }
        
        Task {
            do {
                let domainRecord = RecordMapper.toDomainRecord(
                    flower: selectedFlower,
                    arRecordModel: selectedRecord
                )

//                try await saveRecordUseCase(domainRecord)
                viewData.statusMessage = "성공적으로 저장되었습니다."
                switchToNormalMode()
                await fetchAndPlaceRecords()
            } catch {
                viewData.statusMessage = "저장 실패: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - AR Object & Data Handling
    
    private func fetchAndPlaceRecords() async {
        do {
            let domainRecords = makeMockDomainRecords()
            // TODO: Use RecordARMapper to convert domainRecords to ARRecordModel
            // Placeholder for mapping
            self.allRecords = RecordMapper.toARRecordModels(from: domainRecords)
            viewData.statusMessage = "\(allRecords.count)개의 기록을 불러왔습니다."
            updateSceneWithRecords()
        } catch {
            viewData.statusMessage = "기록을 불러오는데 실패했습니다: \(error.localizedDescription)"
        }
    }
    
    private func updateSceneWithRecords() {
        guard let userHeading = locationManager.heading else { return }
        arSceneManager.updateSceneWithRecords(records: allRecords, userLocation: location, userHeading: userHeading, transformUseCase: transformUseCase)
    }
}

// MARK: - Mock Data
private extension ARCameraViewModel {
    func makeMockDomainRecords() -> [Domain.Record] {
        let titles = ["행복했던 강아지와의 산책", "맛있는 점심", "개발 공부"]
        return titles.map { title in
            let randomCoordinate = generateRandomCoordinate(
                center: self.location.coordinate,
                radiusInMeters: 5
            )
            return .init(
                id: UUID(),
                authorID: UUID(),
                markerTypeID: UUID(),
                title: title,
                coordinate: .init(latitude: randomCoordinate.latitude, longitude: randomCoordinate.longitude),
                address: .init(fullAddress: "서울시 중구"),
                date: .now,
                photos: [],
                isPublic: true
            )
        }
    }

    private func generateRandomCoordinate(center: CLLocationCoordinate2D, radiusInMeters: Double) -> CLLocationCoordinate2D {
        let radiusInDegrees = radiusInMeters / 111_111.0

        let angle = Double.random(in: 0..<(2 * .pi))
        let radius = sqrt(Double.random(in: 0..<1)) * radiusInDegrees

        let newLatitude = center.latitude + radius * cos(angle)
        let newLongitude = center.longitude + radius * sin(angle) / cos(center.latitude * .pi / 180.0)

        return CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
    }
}

// MARK: - CLLocationManagerDelegate
extension ARCameraViewModel: CLLocationManagerDelegate {

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            self.updateSceneWithRecords()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        Task { @MainActor in
            self.updateSceneWithRecords()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.viewData.statusMessage = "위치 정보 오류: \(error.localizedDescription)"
        }
    }
}