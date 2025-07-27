import CoreLocation
import Foundation

@MainActor
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var lastGeocodeTime: Date?
    private var hasStopped = false // ✅ 중복 stop 방지

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var currentAddress: String = "위치 가져오는 중..."

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func checkCurrentLocationAuthorization(status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            self.authorizationStatus = status
        case .restricted, .denied:
            self.authorizationStatus = status
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    
    func requestLocationAgain() {
        hasStopped = false
        manager.startUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.checkCurrentLocationAuthorization(status: status)
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let loc = locations.first else { return }

        Task { @MainActor in
            self.currentLocation = loc

            // 위치 수신 후 바로 stop (중복 방지)
            if !self.hasStopped {
                self.manager.stopUpdatingLocation()
                self.hasStopped = true
            }

            let now = Date()
            if let lastTime = self.lastGeocodeTime,
               now.timeIntervalSince(lastTime) < 5 {
                return
            }

            self.lastGeocodeTime = now
            self.geocode(location: loc)
        }
    }

    private func geocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }

            Task { @MainActor in
                if let placemark = placemarks?.first, error == nil {
                    let province = placemark.administrativeArea ?? ""
                    let city = placemark.locality ?? ""
                    self.currentAddress = "\(province) \(city)"
                } else {
                    self.currentAddress = "주소를 가져올 수 없습니다"
                }
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            print("Location error: \(error)")
            self.currentAddress = "위치를 가져올 수 없습니다"
        }
    }
}
