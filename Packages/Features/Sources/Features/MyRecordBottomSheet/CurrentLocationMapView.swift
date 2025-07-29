import SwiftUI
import MapKit
import CoreLocation
import DesignSystem

struct CurrentLocationMapView: View {
    let location: CLLocationCoordinate2D
    var onTap: (() -> Void)? = nil

    var body: some View {
        let marker = LocationMarker(coordinate: location)
        
        ZStack {
            // 지도 (마커 없이)
            Map(
                coordinateRegion: .constant(
                    MKCoordinateRegion(
                        center: location,
                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    )
                )
            )
            .frame(height: 150)
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
            .frame(height: 150)
            .cornerRadius(12)
            .allowsHitTesting(false)
            
            // 그래픽 아이콘 (좌측 하단에 고정 배치)
            VStack {
                Spacer()
                HStack {
                    Image(systemName: "map.fill")
                        .foregroundColor(DesignSystem.Color.Gray_white)
                        .font(.system(size: 22, weight: .medium))
                        .padding(.leading, 19)
                        .padding(.bottom, 12)
                    Spacer()
                }
            }
            .frame(height: 150)
            .cornerRadius(12)
            .allowsHitTesting(false)

            // 터치 버튼
            Button(action: {
                onTap?()
            }) {
                Color.white.opacity(0.01) // invisible touch area
            }
            .frame(height: 150)
            .cornerRadius(12)
            .buttonStyle(.plain)
        }
    }
}
