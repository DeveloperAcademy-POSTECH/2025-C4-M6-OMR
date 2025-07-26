import CoreLocation
import Foundation
import simd

/// GPS 좌표를 AR 월드 좌표로 변환하는 UseCase
class TransformCoordinateUseCase {

    // MARK: - Configuration
    private let maxVisibleDistance: CLLocationDistance = 100.0  // 100미터
    private let minVisibleDistance: CLLocationDistance = 1.0  // 1미터

    /// GPS 좌표를 AR 월드 위치로 변환합니다.
    ///
    /// - Parameters:
    ///   - userCoordinate: 사용자의 현재 GPS 좌표
    ///   - userHeading: 사용자의 현재 나침반 방향
    ///   - targetCoordinate: 타겟의 GPS 좌표
    /// - Returns: AR 월드에서의 3D 위치 벡터
    func transform(
        userCoordinate: CLLocationCoordinate2D,
        userHeading: CLHeading,
        targetCoordinate: CLLocationCoordinate2D
    ) -> simd_float3 {
        // 사용자와 타겟 간의 거리와 방향 계산
        let distance = GeoUtils.distance(
            from: userCoordinate,
            to: targetCoordinate
        )
        let bearing = GeoUtils.bearing(
            from: userCoordinate,
            to: targetCoordinate
        )

        // 거리 제한 적용
        let clampedDistance = min(
            max(distance, minVisibleDistance),
            maxVisibleDistance
        )

        // 사용자의 방향을 고려하여 상대적 각도 계산
        let relativeAngle = bearing - userHeading.trueHeading
        let angleRadians = Float(relativeAngle * .pi / 180)

        // 극좌표(거리, 각도)를 직교좌표(x, z)로 변환
        // ARKit 좌표계: z축은 전방, x축은 우측
        let x = Float(clampedDistance) * sin(angleRadians)
        let z = -Float(clampedDistance) * cos(angleRadians)

        return simd_float3(x, 0, z)
    }

    /// 편의 메서드: CLLocation 객체들을 직접 받는 버전
    func transform(
        userLocation: CLLocation,
        userHeading: CLHeading,
        targetLocation: CLLocation
    ) -> simd_float3 {
        return transform(
            userCoordinate: userLocation.coordinate,
            userHeading: userHeading,
            targetCoordinate: targetLocation.coordinate
        )
    }

    /// 타겟이 표시 가능한 범위 내에 있는지 확인
    func isWithinDisplayRange(
        from userCoordinate: CLLocationCoordinate2D,
        to targetCoordinate: CLLocationCoordinate2D
    ) -> Bool {
        let distance = GeoUtils.distance(
            from: userCoordinate,
            to: targetCoordinate
        )
        return distance >= minVisibleDistance && distance <= maxVisibleDistance
    }

    /// AR 위치를 GPS 좌표로 역변환 (배치된 객체의 좌표 계산용)
    func reverseTransform(
        arPosition: simd_float3,
        userCoordinate: CLLocationCoordinate2D,
        userHeading: CLHeading
    ) -> CLLocationCoordinate2D {
        // AR 좌표에서 거리와 각도 계산
        let distance = sqrt(
            arPosition.x * arPosition.x + arPosition.z * arPosition.z
        )
        let angle = atan2(arPosition.x, -arPosition.z) * 180 / .pi

        // 사용자 방향을 고려한 절대 방향 계산
        let absoluteBearing = Double(angle) + userHeading.trueHeading

        // 새로운 GPS 좌표 계산
        return GeoUtils.coordinateByMoving(
            from: userCoordinate,
            distance: CLLocationDistance(distance),
            bearing: absoluteBearing
        )
    }
}

enum TransformError: LocalizedError {
    case invalidCoordinates
    case distanceOutOfRange(distance: CLLocationDistance)
    case headingUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidCoordinates:
            return "유효하지 않은 GPS 좌표입니다"
        case .distanceOutOfRange(let distance):
            return "거리가 표시 범위를 벗어났습니다: \(String(format: "%.1f", distance))m"
        case .headingUnavailable:
            return "나침반 방향 정보를 사용할 수 없습니다"
        }
    }
}
