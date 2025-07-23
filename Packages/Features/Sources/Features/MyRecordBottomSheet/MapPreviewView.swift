//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/22/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapPreviewView: View {
    let coordinate: CLLocationCoordinate2D
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("지도")
                .font(
                    Font.custom("Pretendard", size: 18)
                        .weight(.bold)
                )
                .foregroundColor(Color(red: 0.1, green: 0.12, blue: 0.15))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ZStack {
                Map(initialPosition: .region(
                    MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )) {
                    Marker("내 위치", coordinate: coordinate)
                        .tint(.blue)
                }
                .mapStyle(.standard)
                .frame(height: 200)
                .cornerRadius(12)
                .allowsHitTesting(false)
                
                Button(action: onTap) {
                    Color.white.opacity(0.01)
                }
                .frame(height: 200)
                .cornerRadius(12)
                .buttonStyle(.plain)
            }
        }
    }
}

