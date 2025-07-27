import ARKit
import Combine
import CoreLocation
import Dependencies
import DesignSystem
import Domain
import RealityKit
import SwiftUI

@MainActor
class ARCameraViewModel: NSObject, ObservableObject {
    
    // MARK: - Published Properties (직접 관리)
    @Published var statusMessage: String = "AR 세션을 시작합니다..."
    @Published var cameraMode: ARCameraMode = .normal
    @Published var isPlacementConfirmed: Bool = false
    @Published var isLoadingRecords: Bool = false
    @Published var isSavingRecord: Bool = false
    
    // MARK: - Coordinators
    @Published var bottomSheetCoordinator: BottomSheetCoordinator
    
    // MARK: - Private Properties
    private let arSceneManager = ARSceneManager()
    private let locationManager = CLLocationManager()
    private let transformUseCase = TransformCoordinateUseCase()
    private let location: CLLocation
    private var allRecords: [ARRecordModel] = []
    
    // MARK: - Dependencies (UseCase 주입) - 현재 주석 처리
    // @Dependency(\.fetchMyRecordsUseCase) private var fetchMyRecordsUseCase
    // @Dependency(\.saveRecordUseCase) private var saveRecordUseCase
    
    // MARK: - Placement State
    private var currentPlacement: ARPlacementData?
    
    // MARK: - Initialization
    init(
        location: CLLocation,
        bottomSheetCoordinator: BottomSheetCoordinator
    ) {
        self.location = location
        self.bottomSheetCoordinator = bottomSheetCoordinator
        
        super.init()
        
        // 이제 안전하게 self를 캡처할 수 있으므로 여기서 콜백을 바인딩
        self.bottomSheetCoordinator.onCancelPlacement = { [weak self] in
            self?.cancelPlacement()
        }
        
        setupCoordinators()
        setupARSceneManager()
    }
    
    private func setupCoordinators() {
        bottomSheetCoordinator.delegate = self
    }
    
    private func setupARSceneManager() {
        arSceneManager.onRecordTapped = { [weak self] record in
            self?.handleRecordTapped(record)
        }
        
        arSceneManager.onPlacementStateChanged = { [weak self] status in
            self?.handlePlacementStateChanged(status)
        }
    }
    
    // MARK: - Public Methods
    func setupARView(_ arView: ARView) {
        arSceneManager.setupARView(arView)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
    }
    
    func startARSession() {
        Task {
            await fetchAndPlaceRecords()
        }
    }
    
    // MARK: - AR Actions
    func switchToPlacementMode() {
        print("🎯 switchToPlacementMode 호출됨")
        cameraMode = .placement
        isPlacementConfirmed = false
        statusMessage = "배치할 꽃을 선택하세요."
        print("🎯 cameraMode = .placement 설정됨")
        bottomSheetCoordinator.showFlowerSelection()
        print("🎯 꽃 선택 시트 표시 요청됨")
    }
    
    func cancelPlacement() {
        currentPlacement = nil
        arSceneManager.removePlacementObject()
        cameraMode = .normal
        statusMessage = "배치를 취소했습니다."
    }
    
    func confirmPlacement() {
        guard let placement = currentPlacement else {
            statusMessage = "배치할 객체가 없습니다."
            return
        }
        
        arSceneManager.confirmPlacement()
        currentPlacement = ARPlacementData(
            flower: placement.flower,
            position: placement.position,
            isConfirmed: true,
            placedAt: Date()
        )
        isPlacementConfirmed = true
        statusMessage = "배치가 확정되었습니다. 저장 버튼을 눌러 기록을 저장하세요."
    }
    
    func repositionPlacement() {
        guard let placement = currentPlacement else { return }
        
        currentPlacement = ARPlacementData(
            flower: placement.flower,
            position: placement.position,
            isConfirmed: false
        )
        isPlacementConfirmed = false
        arSceneManager.startRepositioning()
        statusMessage = "꽃을 다시 배치하세요."
    }
    
    func requestSave() {
        guard let placement = currentPlacement else { return }
        
        // 현재 위치 정보를 가져와서 주소로 변환
        fetchAddress(from: location) { [weak self] address in
            guard let self else { return }
            
            let saveSheetInfo = RecordSaveSheetInfo(
                flower: placement.flower,
                location: self.location,
                address: address ?? "주소를 찾을 수 없음"
            )
            
            self.bottomSheetCoordinator.showSaveSheet(
                info: saveSheetInfo,
                onSave: { [weak self] finalRecord in
                    self?.handleSaveRecord(
                        placement: placement,
                        finalRecord: finalRecord
                    )
                },
                onCancel: { [weak self] in
                    self?.cancelPlacement()
                }
            )
        }
    }
    
    // MARK: - Private Methods
    private func fetchAddress(
        from location: CLLocation,
        completion: @escaping (String?) -> Void
    ) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error {
                print("주소 변환 실패: \(error.localizedDescription)")
                completion(nil)
                return
            }
            completion(placemarks?.first?.name)
        }
    }
    private func handleRecordTapped(_ record: ARRecordModel) {
        bottomSheetCoordinator.showRecordDetail(record: record)
    }
    
    private func handlePlacementStateChanged(_ status: ARPlacementState.Status)
    {
        switch status {
        case .idle:
            statusMessage = "주변 기록들을 확인해보세요."
        case .placing:
            statusMessage = "꽃을 배치할 위치를 정해주세요."
        case .confirmed:
            statusMessage = "배치가 확정되었습니다. 저장 버튼을 눌러 기록을 저장하세요."
        }
    }
    
    private func handleFlowerSelected(_ flower: FlowerModel) {
        print("🌸 handleFlowerSelected 호출됨: \(flower.name)")
        
        let arFlower = RecordMapper.toARFlower(from: flower)
        print("🌸 ARFlower 변환 완료: \(arFlower.name)")
        
        // TODO: 실제 배치 위치 계산 로직 필요
        let placementPosition = ARCoordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        currentPlacement = ARPlacementData(
            flower: arFlower,
            position: placementPosition,
            isConfirmed: false
        )
        print("🌸 Placement 데이터 설정 완료")
        
        arSceneManager.placeTemporaryObject(flower: arFlower) {
            [weak self] message in
            print("🌸 AR 배치 메시지: \(message)")
            self?.statusMessage = message
        }
        print("🌸 AR 배치 요청 완료")
    }
    
    private func handleSaveRecord(
        placement: ARPlacementData,
        finalRecord: FinalRecordData
    ) {
        isSavingRecord = true
        
        Task {
            do {
                // Domain Record로 변환
                let domainRecord = RecordMapper.toDomainRecord(
                    from: placement,
                    userLocation: location,
                    images: finalRecord.images
                )
                
                // TODO: UseCase를 통해 저장
                // try await saveRecordUseCase(domainRecord)
                
                // Mock: 저장 시뮬레이션
                try await Task.sleep(nanoseconds: 1_000_000_000)  // 1초 대기
                print(
                    "Mock: Record saved - \(domainRecord.title ?? "Untitled")"
                )
                
                statusMessage = "성공적으로 저장되었습니다."
                isSavingRecord = false
                currentPlacement = nil
                cameraMode = .normal
                await fetchAndPlaceRecords()
            } catch {
                statusMessage = "저장 실패: \(error.localizedDescription)"
                isSavingRecord = false
            }
        }
    }
    
    private func fetchAndPlaceRecords() async {
        isLoadingRecords = true
        
        do {
            // TODO: UseCase를 통해 내 주변 기록들 가져오기
            // let recordDetails = try await fetchMyRecordsUseCase(
            //     in: LocationFilter(
            //         center: Coordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),
            //         radius: 100.0
            //     )
            // )
            // let domainRecords = recordDetails.map { $0.record }
            
            // Mock: 가짜 데이터 생성
            let domainRecords = makeMockDomainRecords()
            
            // Domain Record를 AR용 모델로 변환
            allRecords = RecordMapper.toARRecordModels(from: domainRecords)
            statusMessage = "\(allRecords.count)개의 기록을 불러왔습니다."
            updateSceneWithRecords()
        } catch {
            statusMessage = "네트워크 오류: \(error.localizedDescription)"
        }
        
        isLoadingRecords = false
    }
    
    private func updateSceneWithRecords() {
        guard let userHeading = locationManager.heading else { return }
        arSceneManager.updateSceneWithRecords(
            records: allRecords,
            userLocation: location,
            userHeading: userHeading,
            transformUseCase: transformUseCase
        )
    }
    
    // MARK: - Mock Data Generation
    private func makeMockDomainRecords() -> [Domain.Record] {
        let titles = ["행복했던 강아지와의 산책", "맛있는 점심", "개발 공부"]
        
        return titles.map { title in
            let randomCoordinate = generateRandomCoordinate(
                center: self.location.coordinate,
                radiusInMeters: 5.0  // 5미터 반경으로 축소
            )
            
            return Domain.Record(
                id: UUID(),
                authorID: UUID(),
                markerTypeID: UUID(),
                title: title,
                coordinate: Domain.Coordinate(
                    latitude: randomCoordinate.latitude,
                    longitude: randomCoordinate.longitude
                ),
                address: Domain.Address(fullAddress: "포항공과대학교"),
                date: Date().addingTimeInterval(
                    -Double.random(in: 0...3 * 24 * 3600)
                ),  // 최근 3일 내
                photos: [],
                isPublic: true
            )
        }
    }
    
    private func generateRandomCoordinate(
        center: CLLocationCoordinate2D,
        radiusInMeters: Double
    ) -> CLLocationCoordinate2D {
        let radiusInDegrees = radiusInMeters / 111_111.0
        
        let angle = Double.random(in: 0..<(2 * .pi))
        let radius = sqrt(Double.random(in: 0..<1)) * radiusInDegrees
        
        let newLatitude = center.latitude + radius * cos(angle)
        let newLongitude =
        center.longitude + radius * sin(angle)
        / cos(center.latitude * .pi / 180.0)
        
        return CLLocationCoordinate2D(
            latitude: newLatitude,
            longitude: newLongitude
        )
    }
}

// MARK: - BottomSheetCoordinatorDelegate
extension ARCameraViewModel: BottomSheetCoordinatorDelegate {
    func didSelectFlower(_ flower: FlowerModel) {
        print(" didSelectFlower 호출됨: \(flower.name)")
        handleFlowerSelected(flower)
    }
}

// MARK: - CLLocationManagerDelegate
extension ARCameraViewModel: CLLocationManagerDelegate {
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        Task { @MainActor in
            updateSceneWithRecords()
        }
    }
    
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateHeading newHeading: CLHeading
    ) {
        Task { @MainActor in
            updateSceneWithRecords()
        }
    }
    
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        Task { @MainActor in
            statusMessage = "위치 정보 오류: \(error.localizedDescription)"
        }
    }
}
