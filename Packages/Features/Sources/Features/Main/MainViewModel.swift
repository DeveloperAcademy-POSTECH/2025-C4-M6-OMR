import Combine
import Dependencies
import Domain
import Foundation
import CoreLocation

@MainActor
public final class MainViewModel: ObservableObject {
    // MARK: - State
    @Published public var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published public var currentLocation: CLLocation? = nil
    @Published public var currentAddress: String = ""
    @Published public var totalCount: Int = 0
    @Published public var nearbyCount: Int = 0
    @Published public var nearbyRecords: [RecordDetail] = [] // RecordDetail 타입으로 변경
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?

    let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()

    private let fetchMyRecordsUseCase: FetchMyRecordsUseCase
    private let initializeAppDataUseCase: InitializeAppDataUseCase

    public init(
        fetchMyRecordsUseCase: FetchMyRecordsUseCase,
        initializeAppDataUseCase: InitializeAppDataUseCase
    ) {
        self.fetchMyRecordsUseCase = fetchMyRecordsUseCase
        self.initializeAppDataUseCase = initializeAppDataUseCase
        setupAuthorizationSubscription()
        setupAddressGeocoding()
        setupLocationBinding()
        
        Task {
            do {
                let recordDetails = try await fetchMyRecordsUseCase()
//                print("✅ fetchMyRecordsUseCase success: \(recordDetails)")
                
                // 초기 데이터 설정
                await MainActor.run {
                    self.totalCount = recordDetails.count
                    self.nearbyRecords = recordDetails // 초기에는 모든 데이터 표시
                    self.nearbyCount = recordDetails.count
                }
            } catch {
                print("❌ fetchMyRecordsUseCase failed: \(error.localizedDescription)")
                await MainActor.run {
                    self.errorMessage = "데이터 불러오기 실패: \(error.localizedDescription)"
                }
            }
        }
    }
    
    public func initializeAppDataIfNeeded() async throws {
        try await initializeAppDataUseCase()
    }

    public func requestCurrentLocation() {
        locationManager.requestLocationAgain()
    }
    
    private func setupLocationBinding() {
        locationManager.$currentLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loc in
                self?.currentLocation = loc
            }
            .store(in: &cancellables)
    }

    // 실제 RecordDetail 데이터를 사용한 거리 필터링
    public func loadNearbyRecords(center: CLLocation, radius: Double) {
        print("🎯 Starting loadNearbyRecords with center: \(center.coordinate), radius: \(radius)m")
        isLoading = true
        errorMessage = nil

        Task {
            do {
                // 모든 레코드 가져오기
                let allRecords = try await fetchMyRecordsUseCase()
                
                // 거리 계산해서 필터링
                var nearbyRecords: [RecordDetail] = []
                
                for (index, recordDetail) in allRecords.enumerated() {
                    let recordCoordinate = recordDetail.record.coordinate
                    
                    let distance = haversineDistance(
                        lat1: center.coordinate.latitude,
                        lon1: center.coordinate.longitude,
                        lat2: recordCoordinate.latitude,
                        lon2: recordCoordinate.longitude
                    )
                    
                    
                    if distance <= radius {
                        nearbyRecords.append(recordDetail)
                    } else {
                    }
                }
                
                await MainActor.run {
                    self.totalCount = allRecords.count
                    self.nearbyCount = nearbyRecords.count
                    self.nearbyRecords = nearbyRecords
                    self.isLoading = false
                }
                
                
            } catch {
                await MainActor.run {
                    self.errorMessage = "데이터 불러오기 실패: \(error.localizedDescription)"
                    self.isLoading = false
                }
                print("❌ loadNearbyRecords failed: \(error.localizedDescription)")
            }
        }
    }

    // Mock 데이터를 위한 메서드 (기존 코드와 호환성을 위해 유지)
    public func loadNearbyMotesMock(center: CLLocation, radius: Double) {
        isLoading = true
        errorMessage = nil

        Task {
            let allMotes = MockDataProvider.mockObjects()
            await MainActor.run {
                self.totalCount = allMotes.count
            }

            let nearby = allMotes.filter { mote in
                let distance = haversineDistance(
                    lat1: center.coordinate.latitude,
                    lon1: center.coordinate.longitude,
                    lat2: mote.latitude,
                    lon2: mote.longitude
                )
                return distance <= radius
            }

            await MainActor.run {
                self.nearbyCount = nearby.count
                self.isLoading = false
            }
        }
    }

    private func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let R = 6371000.0 // 지구 반지름 (미터)
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2) +
            cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
            sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return R * c
    }

    private func setupAuthorizationSubscription() {
        locationManager.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .assign(to: &$authorizationStatus)
    }

    private func setupAddressGeocoding() {
        locationManager.$currentAddress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] address in
                self?.currentAddress = address
            }
            .store(in: &cancellables)
    }
}
