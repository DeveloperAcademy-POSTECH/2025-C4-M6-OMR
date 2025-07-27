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
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?

    let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()

    @Dependency(\.fetchMyRecordsUseCase) private var fetchMyRecordsUseCase

    public init() {
        setupAuthorizationSubscription()
        setupAddressGeocoding()
        setupLocationBinding()
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


    public func loadNearbyMotesMock(center: CLLocation, radius: Double) {
        isLoading = true
        errorMessage = nil

        Task {
            let allMotes = MockDataProvider.mockObjects()
            self.totalCount = allMotes.count

            let nearby = allMotes.filter { mote in
                let distance = haversineDistance(
                    lat1: center.coordinate.latitude,
                    lon1: center.coordinate.longitude,
                    lat2: mote.latitude,
                    lon2: mote.longitude
                )
                return distance <= radius
            }

            self.nearbyCount = nearby.count
            self.isLoading = false
        }
    }

    private func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let R = 6371000.0
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
