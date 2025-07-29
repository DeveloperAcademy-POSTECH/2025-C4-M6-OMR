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

    // MARK: - Placement State
    private var currentPlacement: ARPlacementData?

    // MARK: - Initialization
    init(
        fetchMyRecordsUseCase: FetchMyRecordsUseCase,
        saveRecordUseCase: SaveRecordUseCase,
        location: CLLocation,
        bottomSheetCoordinator: BottomSheetCoordinator
    ) {
        self.fetchMyRecordsUseCase = fetchMyRecordsUseCase
        self.saveRecordUseCase = saveRecordUseCase
        self.location = location
        self.bottomSheetCoordinator = bottomSheetCoordinator

        super.init()

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

        arSceneManager.onFocusStateChanged = { [weak self] isFocused in
            self?.isFocused = isFocused
        }
        
        arSceneManager.onHeadingUpdated = { [weak self] heading, direction in
            self?.currentHeading = heading
            self?.currentDirection = direction
        }
    }

    // MARK: - Public Methods
    func setupARView(_ arView: ARView) {
        arSceneManager.setup(arView: arView)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
    }

    func startARSession() {
        print("🚀 AR 세션 시작")

        // 위치 서비스 시작
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()

        // 데이터 로드 및 배치
        Task {
            await fetchAndPlaceRecords()
        }
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
                onSave: { [weak self] payload in
                    self?.handleSaveRecord(
                        placement: placement,
                        payload: payload
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
            let recordDetails = try await fetchMyRecordsUseCase(
                in: LocationFilter(
                    center: Coordinate(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    ),
                    radius: 100.0
                )
            )
            let domainRecords = recordDetails.map { $0.record }
            let mappedRecords = RecordMapper.toARRecordModels(
                from: domainRecords
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

    // MARK: - Mock Data Generation
    private func makeMockDomainRecords() -> [Domain.Record] {
        print("📊 Mock 데이터 생성 시작")

        let titles = ["행복했던 강아지와의 산책", "맛있는 점심", "개발 공부"]
        let distances: [Double] = [1.0, 3.0, 5.0]  // 1m, 3m, 5m
        let bearings: [Double] = [0.0, 120.0, 240.0]  // 북쪽, 남동쪽, 남서쪽

        var records: [Domain.Record] = []

        for i in 0..<titles.count {
            let title = titles[i]
            let distance = distances[i]
            let bearing = bearings[i]

            // TransformUseCase를 사용하여 유효한 좌표 생성
            let targetCoordinate = transformUseCase.generateValidTestCoordinate(
                from: self.location.coordinate,
                distance: distance,
                bearing: bearing
            )

            let record = Domain.Record(
                id: UUID(),
                authorID: UUID(),
                markerTypeID: UUID(),
                title: title,
                coordinate: Domain.Coordinate(
                    latitude: targetCoordinate.latitude,
                    longitude: targetCoordinate.longitude
                ),
                address: Domain.Address(fullAddress: "포항공과대학교"),
                date: Date().addingTimeInterval(
                    -Double.random(in: 0...3 * 24 * 3600)
                ),  // 최근 3일 내
                photos: [],
                isPublic: true
            )

            print("📍 Mock 레코드 생성: \(title) at \(targetCoordinate)")
            records.append(record)
        }

        return records
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
            statusMessage = "위치 정보 오류: \(error.localizedDescription)"
        }
    }
}
