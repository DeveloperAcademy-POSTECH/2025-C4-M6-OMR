//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/18/25.
//

//
//  LocationManager.swift
//  Features
//
//  Simplified permission and location manager

import CoreLocation
import Foundation

@MainActor
final class LocationManager: NSObject, ObservableObject,
    CLLocationManagerDelegate
{
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var lastGeocodeTime: Date? = nil

    /// 현재 권한 상태
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    /// 현재 위치
    @Published var currentLocation: CLLocation? = nil
    @Published var currentAddress: String = "위치 가져오는 중..."

    override init() {
        super.init()
        manager.delegate = self
        print("LocationManager initialized.")
        // 즉시 권한 요청 (팝업 표시)
        manager.requestWhenInUseAuthorization()
    }

    /// CLLocationManagerDelegate: 권한 상태 변경 콜백
    nonisolated func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        let status = manager.authorizationStatus
        // 비동기 Task 안에서 MainActor로 전환 후 호출
        Task { @MainActor in
            self.checkCurrentLocationAuthorization(status: status)
        }
    }

    func checkCurrentLocationAuthorization(status: CLAuthorizationStatus) {
        print("Location authorization status changed: \(status.rawValue)")
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // Location services enabled
            manager.startUpdatingLocation()
            let newStatus = manager.authorizationStatus
            Task { @MainActor in
                self.authorizationStatus = newStatus
            }
            print(
                "Authorization granted. Started updating location. New status: \(newStatus.rawValue)"
            )
        case .restricted, .denied:
            // Location services unavailable
            manager.stopUpdatingLocation()
            let newStatus = manager.authorizationStatus
            Task { @MainActor in
                self.authorizationStatus = newStatus
            }
            print(
                "Authorization denied/restricted. Stopped updating location. New status: \(newStatus.rawValue)"
            )
        case .notDetermined:
            // Request permission if not determined
            manager.requestWhenInUseAuthorization()
            print(
                "Authorization not determined. Requested when in use authorization."
            )
        @unknown default:
            break
        }
    }

    /// CLLocationManagerDelegate: 위치 업데이트 콜백
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let loc = locations.first else { return }
        print(
            "Received location update: \(loc.coordinate.latitude), \(loc.coordinate.longitude)"
        )
        Task { @MainActor in
            self.currentLocation = loc
            print("LocationManager.currentLocation set to: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")

            // 마지막 역지오코딩 호출 시각 체크 (예: 5초 이상 지났을 때만)
            let now = Date()
            if let lastTime = lastGeocodeTime,
                now.timeIntervalSince(lastTime) < 5
            {
                // 5초 안 지났으면 호출하지 않음
                print(
                    "역지오코딩 호출 제한: \(now.timeIntervalSince(lastTime))초 후에 다시 시도"
                )
                return
            }
            lastGeocodeTime = now
            self.geocode(location: loc)
        }
    }

    /// 위치 → 주소 변환 (역 지오코딩)
    private func geocode(location: CLLocation) {
        print(
            "Geocoding location: \(location.coordinate.latitude), \(location.coordinate.longitude)"
        )
        geocoder.reverseGeocodeLocation(location) {
            [weak self] placemarks, error in
            print(
                "Reverse geocode callback: placemarks=\(String(describing: placemarks)), error=\(String(describing: error))"
            )
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let placemark = placemarks?.first, error == nil {
                    let province = placemark.administrativeArea ?? ""
                    let city = placemark.locality ?? ""
                    let address = "\(province) \(city)"
                    print("주소 : \(province) \(city) ")
                    self.currentAddress = address
                    print("LocationManager.currentAddress set to: \(self.currentAddress)")
                } else {
                    print("주소를 가져올 수 없습니다")
                    self.currentAddress = "주소를 가져올 수 없습니다"
                    print("LocationManager.currentAddress set to: \(self.currentAddress)")
                }
            }
        }
    }

    /// CLLocationManagerDelegate: 에러 발생 콜백
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("LocationManager encountered an error: \(error)")
        Task { @MainActor in
            // 필요시 에러 핸들링
            print("Location error: \(error)")
        }
    }
}
