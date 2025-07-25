import SwiftUI
import MapKit
import CoreLocation

struct CurrentLocationMapView: View {
    let location: CLLocationCoordinate2D
    var onTap: (() -> Void)? = nil

    var body: some View {
        let marker = LocationMarker(coordinate: location)
        
        ZStack {
            Map(
                coordinateRegion: .constant(
                    MKCoordinateRegion(
                        center: location,
                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    )
                ),
                annotationItems: [marker]
            ) { item in
                MapMarker(coordinate: item.coordinate, tint: .blue)
            }
            .frame(height: 200)
            .cornerRadius(12)
            .allowsHitTesting(false)

            Button(action: {
                onTap?()
            }) {
                Color.white.opacity(0.01) // invisible touch area
            }
            .frame(height: 200)
            .cornerRadius(12)
            .buttonStyle(.plain)
        }
    }
}
