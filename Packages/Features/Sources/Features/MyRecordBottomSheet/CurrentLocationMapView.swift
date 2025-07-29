import SwiftUI
import MapKit
import CoreLocation

struct CurrentLocationMapView: View {
    let location: CLLocationCoordinate2D
    var onTap: (() -> Void)? = nil

    var body: some View {
        let marker = LocationMarker(coordinate: location)
        
        ZStack {
            // 지도
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
            
            // 그라데이션 오버레이 (아래쪽에만)
            VStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(height: 86)
                    .background(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: Color(red: 0.1, green: 0.12, blue: 0.15).opacity(0), location: 0.00),
                                Gradient.Stop(color: Color(red: 0.1, green: 0.12, blue: 0.15).opacity(0.4), location: 1.00),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0),
                            endPoint: UnitPoint(x: 0.5, y: 1)
                        )
                    )
            }
            .frame(height: 200)
            .cornerRadius(12)
            .allowsHitTesting(false)

            // 터치 버튼
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
