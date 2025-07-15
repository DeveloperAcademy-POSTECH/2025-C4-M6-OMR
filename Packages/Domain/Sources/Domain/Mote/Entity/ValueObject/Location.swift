import Foundation

/// Location: 위도와 경도를 나타내는 값 객체 (Value Object)
public struct Location: Equatable, Sendable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
