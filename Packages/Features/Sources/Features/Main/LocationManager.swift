//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/18/25.
//

import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    @Published var currentAddress: String = "위치 가져오는 중..."
    @Published var currentLocation: CLLocation? = nil

    private var lastGeocodeTime: Date?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        currentLocation = location

        // 마지막 역지오코딩 호출 시각 체크 (예: 5초 이상 지났을 때만)
        let now = Date()
        if let lastTime = lastGeocodeTime, now.timeIntervalSince(lastTime) < 5 {
            // 5초 안 지났으면 호출하지 않음
            print("역지오코딩 호출 제한: \(now.timeIntervalSince(lastTime))초 후에 다시 시도")
            return
        }
        lastGeocodeTime = now
        geocode(location: location)
    }

    private func geocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                self?.currentAddress = "주소를 가져올 수 없습니다"
                return
            }

            let province = placemark.administrativeArea ?? ""
            let city = placemark.locality ?? ""
            self?.currentAddress = "\(province) \(city)"
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        currentAddress = "위치 오류: \(error.localizedDescription)"
    }
}




public struct Location {
    public let latitude: Double
    public let longitude: Double
}

