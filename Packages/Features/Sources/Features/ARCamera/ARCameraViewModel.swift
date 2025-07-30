import ARKit
import Combine
import CoreLocation
import Dependencies
import DesignSystem
import Domain
import RealityKit
import SwiftUI

@available(iOS 18.0, *)
@MainActor
public class ARCameraViewModel: NSObject, ObservableObject {

    // MARK: - Published Properties (직접 관리)
    @Published var statusMessage: String = "AR 세션을 시작합니다..."
    @Published var cameraMode: ARCameraMode = .normal
    @Published var isPlacementConfirmed: Bool = false
    @Published var isLoadingRecords: Bool = false
    @Published var isSavingRecord: Bool = false
    @Published var isFocused: Bool = false
    
    // MARK: - Real-time Heading Info
    @Published var currentHeading: Double = 0.0
    @Published var currentDirection: String = "북쪽"

    // MARK: - Public Properties
    let arSceneManager = ARSceneManager()

    // MARK: - Coordinators
    @Published var bottomSheetCoordinator: BottomSheetCoordinator

    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    private let transformUseCase = TransformCoordinateUseCase()
    private let location: CLLocation
    private var allRecords: [ARRecordModel] = []

    // 의존성 명시적 주입
    private let fetchMyRecordsUseCase: FetchMyRecordsUseCase
    private let saveRecordUseCase: SaveRecordUseCase
    private let initializeAppDataUseCase: InitializeAppDataUseCase
    private let fetchAllMarkersUseCase: FetchAllMarkersUseCase

    // MARK: - Placement State
    private var currentPlacement: ARPlacementData?
    
    // MARK: - Real-time Camera Orientation (추가)
    @Published var currentPitch: Double = 0.0
    @Published var currentPitchDirection: String = "수평"

    // MARK: - RayCast Status (추가)
    @Published var raycastStatus: ARSceneManager.RaycastStatus = .idle
    @Published var raycastDistance: Float = 0.0
    private var cancellables = Set<AnyCancellable>()


    // MARK: - Initialization
    init(
        fetchMyRecordsUseCase: FetchMyRecordsUseCase,
        saveRecordUseCase: SaveRecordUseCase,
        initializeAppDataUseCase: InitializeAppDataUseCase,
        fetchAllMarkersUseCase: FetchAllMarkersUseCase,
        location: CLLocation,
        bottomSheetCoordinator: BottomSheetCoordinator
    ) {
        self.fetchMyRecordsUseCase = fetchMyRecordsUseCase
        self.saveRecordUseCase = saveRecordUseCase
        self.initializeAppDataUseCase = initializeAppDataUseCase
        self.fetchAllMarkersUseCase  = fetchAllMarkersUseCase
        self.location = location
        self.bottomSheetCoordinator = bottomSheetCoordinator

        super.init()

        self.bottomSheetCoordinator.onCancelPlacement = { [weak self] in
            self?.cancelPlacement()
        }
        Task {
            do {
                try await initializeAppDataIfNeeded()
            } catch {
                print("초기화 실패: \(error.localizedDescription)")
            }
        }
        
        setupCoordinators()
        setupARSceneManager()
    }
    
    public func initializeAppDataIfNeeded() async throws {
        try await initializeAppDataUseCase()
        let markers = try await fetchAllMarkersUseCase()
        print("initializeAppDataIfNeeded \(markers)")
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

        arSceneManager.onFocusStateChanged = { [weak self] isFocused in
            self?.isFocused = isFocused
        }
        
        arSceneManager.onHeadingUpdated = { [weak self] heading, direction in
            self?.currentHeading = heading
            self?.currentDirection = direction
        }
        
        // setupARSceneManager() 메서드에 추가할 콜백
        arSceneManager.onCameraOrientationUpdated = { [weak self] pitch, pitchDirection in
            self?.currentPitch = pitch
            self?.currentPitchDirection = pitchDirection
        }
        
        // RayCast 상태 콜백 추가
        arSceneManager.$raycastStatus
                   .receive(on: DispatchQueue.main)
                   .sink { [weak self] status in
                       self?.raycastStatus = status
                   }
                   .store(in: &cancellables)
               
               arSceneManager.$lastRaycastDistance
                   .receive(on: DispatchQueue.main)
                   .sink { [weak self] distance in
                       self?.raycastDistance = distance
                   }
                   .store(in: &cancellables)
    }

    // MARK: - Public Methods
    func setupARView(_ arView: ARView) {
        arSceneManager.setup(arView: arView)
        locationManager.delegate = self
    }

    func startARSession() {
        print("🚀 AR 세션 시작")

        // ✅ 권한 상태 확인 후 위치 서비스 시작 (한 번만)
        checkLocationPermissionAndStart()

        // 데이터 로드 및 배치
        Task {
            await fetchAndPlaceRecords()
        }
    }

    // MARK: - Location Permission Management
    
    /// 위치 권한을 확인하고 안전하게 위치 서비스를 시작합니다.
    private func checkLocationPermissionAndStart() {
        let authStatus = locationManager.authorizationStatus
        
        switch authStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // ✅ 권한이 있으면 위치 서비스 시작
            startLocationServices()
            
        case .notDetermined:
            // ✅ 권한이 결정되지 않았으면 요청
            locationManager.requestWhenInUseAuthorization()
            
        case .denied, .restricted:
            // ❌ 권한이 거부되었으면 에러 메시지 표시
            statusMessage = "위치 권한이 필요합니다. 설정에서 위치 접근을 허용해주세요."
            
        @unknown default:
            // ❓ 알 수 없는 상태면 권한 요청
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    /// 실제로 위치 서비스를 시작합니다.
    private func startLocationServices() {
        guard locationManager.authorizationStatus == .authorizedWhenInUse || 
              locationManager.authorizationStatus == .authorizedAlways else {
            print("❌ 위치 권한이 없어서 위치 서비스를 시작할 수 없습니다.")
            return
        }
        
        print("✅ 위치 서비스 시작")
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
    }

    // MARK: - AR Actions
    func switchToPlacementMode() {
        guard cameraMode != .placement else {
            showFlowerSelectionSheet()
            return
        }

        print("🎯 switchToPlacementMode 호출됨")
        cameraMode = .placement
        isPlacementConfirmed = false
        statusMessage = "배치할 꽃을 선택하세요."
        print("🎯 cameraMode = .placement 설정됨")
        
        showFlowerSelectionSheet()
    }
    
    func showFlowerSelectionSheet() {
        bottomSheetCoordinator.showFlowerSelection()
    }

    func cancelPlacement() {
        currentPlacement = nil
        arSceneManager.removePlacementObject()
        cameraMode = .normal
        statusMessage = "배치를 취소했습니다."
    }

    func confirmPlacement() {
        print("🔥 confirmPlacement() 호출 시작")
        guard let placement = currentPlacement else {
            statusMessage = "배치할 객체가 없습니다."
            print("❌ currentPlacement가 nil")
            return
        }
        
        print("🔥 현재 placement 위치: (\(String(format: "%.6f", placement.position.latitude)), \(String(format: "%.6f", placement.position.longitude)))")

        // ✅ arSceneManager.confirmPlacement() 호출 전에 실제 위치 가져오기
        print("🔥 getCurrentPlacementCoordinate() 호출 시도... (confirmPlacement 이전)")
        let updatedPosition: ARCoordinate
        if let actualCoordinate = arSceneManager.getCurrentPlacementCoordinate() {
            updatedPosition = ARCoordinate(
                latitude: actualCoordinate.latitude,
                longitude: actualCoordinate.longitude
            )
            print("🌸 배치 위치 업데이트 성공: (\(String(format: "%.6f", actualCoordinate.latitude)), \(String(format: "%.6f", actualCoordinate.longitude)))")
        } else {
            // Fallback: 기존 위치 유지
            updatedPosition = placement.position
            print("⚠️ 실제 위치 가져오기 실패, 기존 위치 유지: (\(String(format: "%.6f", placement.position.latitude)), \(String(format: "%.6f", placement.position.longitude)))")
        }
        
        print("🔥 최종 업데이트될 위치: (\(String(format: "%.6f", updatedPosition.latitude)), \(String(format: "%.6f", updatedPosition.longitude)))")

        // ✅ 위치 정보 확보 후 confirmPlacement 호출
        arSceneManager.confirmPlacement()
        print("🔥 arSceneManager.confirmPlacement() 완료")
        
        currentPlacement = ARPlacementData(
            flower: placement.flower,
            position: updatedPosition,
            isConfirmed: true,
            placedAt: Date()
        )
        isPlacementConfirmed = true
        statusMessage = "다른 곳을 비쳐서 재배치 버튼을 탭하면\n다시 심을 수 있어요"
        print("🔥 confirmPlacement() 완료")
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
        statusMessage = "🔴 여기에 \(currentPlacement?.flower.name ?? "")를 심을까요?"
    }

    func requestSave() {
        guard let placement = currentPlacement else { return }

        arSceneManager.pauseARSession()

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
                onSave: { [weak self] payload in
                    self?.arSceneManager.resumeARSession()
                    self?.handleSaveRecord(
                        placement: placement,
                        payload: payload
                    )
                },
                onCancel: { [weak self] in
                    self?.arSceneManager.resumeARSession()
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

        // ✅ 임시 위치로 설정 (confirmPlacement에서 실제 배치 위치로 업데이트됨)
        let temporaryPosition = ARCoordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        print("🌸 임시 위치 설정: (\(String(format: "%.6f", temporaryPosition.latitude)), \(String(format: "%.6f", temporaryPosition.longitude)))")

        currentPlacement = ARPlacementData(
            flower: arFlower,
            position: temporaryPosition,
            isConfirmed: false
        )
        print("🌸 Placement 데이터 설정 완료 (임시 위치)")

        arSceneManager.placeTemporaryObject(flower: arFlower) {
            [weak self] message in
            print("🌸 AR 배치 메시지: \(message)")
            self?.statusMessage = message
        }
        print("🌸 AR 배치 요청 완료")
    }

    private func handleSaveRecord(
        placement: ARPlacementData,
        payload: FinalRecordPayload
    ) {
        isSavingRecord = true

        Task {
            do {
                // Domain Record로 변환
                let domainRecord = RecordMapper.toDomainRecord(
                    from: placement,
                    userLocation: location,
                    payload: payload
                )

                try await saveRecordUseCase(domainRecord)

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
            print("[ViewModel] fetchMyRecordsUseCase 요청")
            let recordDetails = try await fetchMyRecordsUseCase(
                in: LocationFilter(
                    center: Coordinate(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    ),
                    radius: 100.0
                )
            )
            print("[ViewModel]  \(recordDetails.count) 요청")
//            let domainRecords = recordDetails.map { $0.record }
            let mappedRecords = RecordMapper.toARRecordModels(
                from: recordDetails
            )
            
            await MainActor.run {
                self.allRecords = mappedRecords
                self.statusMessage = "\(mappedRecords.count)개의 기록을 불러왔습니다."
                self.updateSceneWithRecords()
            }
        } catch {
            await MainActor.run {
                self.statusMessage = "네트워크 오류: \(error.localizedDescription)"
            }
        }

        isLoadingRecords = false
    }

    private func updateSceneWithRecords() {
        guard let userHeading = locationManager.heading else {
            print("❌ 사용자 방향 정보 없음")
            return
        }

        arSceneManager.updateSceneWithRecords(
            records: allRecords,
            userLocation: location,
            userHeading: userHeading,
            transformUseCase: transformUseCase
        )
    }

}

// MARK: - BottomSheetCoordinatorDelegate
@available(iOS 18.0, *)
extension ARCameraViewModel: BottomSheetCoordinatorDelegate {
    func didSelectFlower(_ flower: FlowerModel) {
        print(" didSelectFlower 호출됨: \(flower.name)")
        handleFlowerSelected(flower)
    }

    func didDismissBottomSheet() {
        arSceneManager.deselectCurrentMarker()
    }
}

// MARK: - CLLocationManagerDelegate
@available(iOS 18.0, *)
extension ARCameraViewModel: CLLocationManagerDelegate {
    public nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        Task { @MainActor in
            updateSceneWithRecords()
        }
    }

    public nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateHeading newHeading: CLHeading
    ) {
        Task { @MainActor in
            updateSceneWithRecords()
        }
    }

    public nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        Task { @MainActor in
            print("❌ 위치 정보 오류: \(error.localizedDescription)")
            statusMessage = "위치 정보 오류: \(error.localizedDescription)"
            
            // GPS 신호 문제인 경우 재시도 유도
            if let clError = error as? CLError, clError.code == .locationUnknown {
                statusMessage = "GPS 신호를 찾고 있습니다. 잠시 후 다시 시도해주세요."
            }
        }
    }
    
    /// 권한 상태가 변경되었을 때 호출됩니다.
    public nonisolated func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        Task { @MainActor in
            print("📍 위치 권한 상태 변경: \(status.rawValue)")
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                print("✅ 위치 권한 승인됨")
                startLocationServices()
                
            case .denied, .restricted:
                print("❌ 위치 권한 거부됨")
                statusMessage = "위치 권한이 필요합니다. 설정에서 위치 접근을 허용해주세요."
                
            case .notDetermined:
                print("❓ 위치 권한 미결정")
                statusMessage = "위치 권한을 확인하고 있습니다..."
                
            @unknown default:
                print("❓ 알 수 없는 위치 권한 상태")
            }
        }
    }
}
