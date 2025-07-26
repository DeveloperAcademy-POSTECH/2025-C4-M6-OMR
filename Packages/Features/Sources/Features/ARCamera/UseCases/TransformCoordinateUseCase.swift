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
        print("🔄 좌표 변환 시작:")
        print("  사용자: \(userCoordinate.latitude), \(userCoordinate.longitude)")
        print(
            "  타겟: \(targetCoordinate.latitude), \(targetCoordinate.longitude)"
        )
        print("  방향: \(userHeading.trueHeading)°")

        // 사용자와 타겟 간의 거리와 방향 계산
        let distance = GeoUtils.distance(
            from: userCoordinate,
            to: targetCoordinate
        )
        let bearing = GeoUtils.bearing(
            from: userCoordinate,
            to: targetCoordinate
        )

        print("  실제 거리: \(String(format: "%.2f", distance))m")
        print("  방위각: \(String(format: "%.2f", bearing))°")

        // 거리 제한 적용
        let clampedDistance = min(
            max(distance, minVisibleDistance),
            maxVisibleDistance
        )

        print("  제한된 거리: \(String(format: "%.2f", clampedDistance))m")

        // 사용자의 방향을 고려하여 상대적 각도 계산
        let relativeAngle = bearing - userHeading.trueHeading
        let angleRadians = Float(relativeAngle * .pi / 180)

        print("  상대각도: \(String(format: "%.2f", relativeAngle))°")

        // 극좌표(거리, 각도)를 직교좌표(x, z)로 변환
        // ARKit 좌표계: z축은 전방, x축은 우측
        let x = Float(clampedDistance) * sin(angleRadians)
        let z = -Float(clampedDistance) * cos(angleRadians)

        let result = simd_float3(x, 0, z)
        let arDistance = length(result)

        print(
            "  AR 위치: x=\(String(format: "%.2f", x)), y=0, z=\(String(format: "%.2f", z))"
        )
        print("  AR 거리: \(String(format: "%.2f", arDistance))m")

        // 비정상적인 결과 감지
        if arDistance > 100.0 {
            print("⚠️ 경고: AR 거리가 100m를 초과함")
        }
        if arDistance < 0.1 {
            print("⚠️ 경고: AR 거리가 0.1m 미만")
        }
        if x.isNaN || z.isNaN {
            print("❌ 오류: NaN 값 발생")
        }

        return result
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
        let isWithin =
            distance >= minVisibleDistance && distance <= maxVisibleDistance

        print(
            "📏 범위 확인: 거리 \(String(format: "%.2f", distance))m, 범위 내: \(isWithin)"
        )

        return isWithin
    }

    /// AR 위치를 GPS 좌표로 역변환 (배치된 객체의 좌표 계산용)
    func reverseTransform(
        arPosition: simd_float3,
        userCoordinate: CLLocationCoordinate2D,
        userHeading: CLHeading
    ) -> CLLocationCoordinate2D {
        print("🔄 역변환 시작: AR 위치 \(arPosition)")

        // AR 좌표에서 거리와 각도 계산
        let distance = sqrt(
            arPosition.x * arPosition.x + arPosition.z * arPosition.z
        )
        let angle = atan2(arPosition.x, -arPosition.z) * 180 / .pi

        // 사용자 방향을 고려한 절대 방향 계산
        let absoluteBearing = Double(angle) + userHeading.trueHeading

        print("  계산된 거리: \(String(format: "%.2f", distance))m")
        print("  계산된 방위각: \(String(format: "%.2f", absoluteBearing))°")

        // 새로운 GPS 좌표 계산
        let result = GeoUtils.coordinateByMoving(
            from: userCoordinate,
            distance: CLLocationDistance(distance),
            bearing: absoluteBearing
        )

        print("  결과 좌표: \(result.latitude), \(result.longitude)")

        return result
    }

    /// 디버그용: Mock 데이터 생성 시 사용할 수 있는 유효한 좌표 생성
    func generateValidTestCoordinate(
        from userCoordinate: CLLocationCoordinate2D,
        distance: CLLocationDistance,
        bearing: Double
    ) -> CLLocationCoordinate2D {
        // 유효한 범위 내의 거리로 제한
        let validDistance = min(
            max(distance, minVisibleDistance),
            maxVisibleDistance
        )

        let result = GeoUtils.coordinateByMoving(
            from: userCoordinate,
            distance: validDistance,
            bearing: bearing
        )

        print(
            "🧪 테스트 좌표 생성: \(validDistance)m, \(bearing)° → \(result.latitude), \(result.longitude)"
        )

        return result
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
