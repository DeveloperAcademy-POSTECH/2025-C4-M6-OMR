import CoreLocation
import Foundation

/// A utility class for geographic calculations.
enum GeoUtils {
    /// 두 GPS 좌표 간의 미터 단위 거리 계산
    static func distance(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D
    ) -> CLLocationDistance {
        let startLocation = CLLocation(
            latitude: start.latitude,
            longitude: start.longitude
        )
        let endLocation = CLLocation(
            latitude: end.latitude,
            longitude: end.longitude
        )
        return startLocation.distance(from: endLocation)
    }

    /// 시작점에서 끝점으로의 방위각(도 단위) 계산
    static func bearing(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D
    ) -> Double {
        let lat1 = start.latitude * .pi / 180
        let lon1 = start.longitude * .pi / 180
        let lat2 = end.latitude * .pi / 180
        let lon2 = end.longitude * .pi / 180

        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)

        var bearingDegrees = radiansBearing * 180 / .pi

        // 0-360도 범위로 정규화
        if bearingDegrees < 0 {
            bearingDegrees += 360
        }

        return bearingDegrees
    }

    /// 시작점에서 특정 방향과 거리만큼 이동한 좌표 계산
    static func coordinateByMoving(
        from start: CLLocationCoordinate2D,
        distance: CLLocationDistance,
        bearing: Double
    ) -> CLLocationCoordinate2D {
        let earthRadius = 6371000.0  // 지구 반지름 (미터)

        let lat1 = start.latitude * .pi / 180
        let lon1 = start.longitude * .pi / 180
        let bearingRadians = bearing * .pi / 180

        let lat2 = asin(
            sin(lat1) * cos(distance / earthRadius) + cos(lat1)
                * sin(distance / earthRadius) * cos(bearingRadians)
        )

        let lon2 =
            lon1
            + atan2(
                sin(bearingRadians) * sin(distance / earthRadius) * cos(lat1),
                cos(distance / earthRadius) - sin(lat1) * sin(lat2)
            )

        return CLLocationCoordinate2D(
            latitude: lat2 * 180 / .pi,
            longitude: lon2 * 180 / .pi
        )
    }

    /// 좌표가 유효한지 검증
    static func isValidCoordinate(_ coordinate: CLLocationCoordinate2D) -> Bool
    {
        return CLLocationCoordinate2DIsValid(coordinate)
            && coordinate.latitude >= -90 && coordinate.latitude <= 90
            && coordinate.longitude >= -180 && coordinate.longitude <= 180
    }
}
