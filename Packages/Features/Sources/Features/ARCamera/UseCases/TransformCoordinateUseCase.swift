import Foundation
import CoreLocation
import simd

/// A use case for transforming coordinates between the real world (GPS) and the AR world.
class TransformCoordinateUseCase {
    /// Transforms a target GPS coordinate into an AR world position relative to the user's current location and heading.
    ///
    /// - Parameters:
    ///   - userCoordinate: The user's current GPS coordinate.
    ///   - userHeading: The user's current compass heading.
    ///   - targetCoordinate: The target's GPS coordinate.
    /// - Returns: A 3D vector representing the position in the AR world.
    func transform(
        userCoordinate: CLLocationCoordinate2D,
        userHeading: CLHeading,
        targetCoordinate: CLLocationCoordinate2D
    ) -> simd_float3 {
        // Calculate the distance and bearing from the user to the target.
        let distance = GeoUtils.distance(from: userCoordinate, to: targetCoordinate)
        let bearing = GeoUtils.bearing(from: userCoordinate, to: targetCoordinate)

        // Adjust the bearing by the user's heading to get the angle relative to the user's view.
        let angle = bearing - userHeading.trueHeading
        let angleRadians = Float(angle * .pi / 180)

        // Convert the polar coordinates (distance, angle) to Cartesian coordinates (x, z).
        // In ARKit's coordinate system, the z-axis is forward, and the x-axis is to the right.
        let x = Float(distance) * sin(angleRadians)
        let z = -Float(distance) * cos(angleRadians)

        return simd_float3(x, 0, z)
    }
}
