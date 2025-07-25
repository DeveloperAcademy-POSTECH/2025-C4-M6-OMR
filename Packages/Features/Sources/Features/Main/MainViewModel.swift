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
    @Published public var motes: [MainMote] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?

    // MARK: - Private
    let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Dependencies
    @Dependency(\.fetchMyRecordsUseCase) private var fetchMyRecordsUseCase

    public init() {
        setupLocationSubscriptions()
        setupAddressGeocoding()
    }
    
    // MARK: - Public Methods
    public func updateLocation(_ location: CLLocation) {
        self.currentLocation = location
    }

    public func loadNearbyMotesMock(radius: Double) {
        guard let center = currentLocation else {
            errorMessage = "No location available"
            return
        }
        isLoading = true
        errorMessage = nil

        Task {
            let allMotes = MockDataProvider.mockObjects()
            let filtered = allMotes.filter { mote in
                let distance = haversineDistance(
                    lat1: center.coordinate.latitude,
                    lon1: center.coordinate.longitude,
                    lat2: mote.latitude,
                    lon2: mote.longitude
                )
                print("mote: \(mote.title), distance: \(distance) meters")
                return distance <= radius
            }

            self.motes = filtered.map {
                MainMote(id: $0.id, latitude: $0.latitude, longitude: $0.longitude)
            }

            self.isLoading = false
        }
    }
    
    
    
    // Haversine 거리 계산 (미터 단위)
    private func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let R = 6371000.0 // 지구 반지름 (m)
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180
        let a = sin(dLat/2) * sin(dLat/2) +
        cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
        sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return R * c
    }
    
    // MARK: - Subscription Setup
    private func setupLocationSubscriptions() {
        locationManager.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .assign(to: &$authorizationStatus)
        locationManager.$currentLocation
            .receive(on: DispatchQueue.main)
//            .removeDuplicates(by: { $0.coordinate.latitude == $1.coordinate.latitude && $0.coordinate.longitude == $1.coordinate.longitude })
            .sink { [weak self] location in
                guard let self = self else { return }
                self.currentLocation = location
                print("MainViewModel received currentLocation: \(location?.coordinate.longitude)")
                // Automatically load motes when location updates
                self.loadNearbyMotesMock(radius: 1000)
            }
            .store(in: &cancellables)
    }

    private func setupAddressGeocoding() {
        locationManager.$currentAddress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] address in
                self?.currentAddress = address
                print("MainViewModel received currentAddress: \(address)")
            }
            .store(in: &cancellables)
    }
}
