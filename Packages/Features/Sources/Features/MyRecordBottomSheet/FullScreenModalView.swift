//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/21/25.
//

import SwiftUI
import MapKit
import CoreLocation


struct FullScreenModalView: View {
    @Binding var isPresented: Bool
    var locationManager: LocationManager
    @StateObject private var viewModel = MyRecordBottomSheetViewModel()
    
    var body: some View {
        ZStack {
            
            VStack(alignment: .leading, spacing: 12) {
                RoundedRectangle(cornerRadius: 3)
                    .frame(width: 40, height: 5)
                    .foregroundColor(.gray.opacity(0.4))
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
                HStack {
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                
                Text("내 꽃")
                    .font(.headline)
                
                Button(action: {
                    // 전체 기록 보기 이동 등
                }) {
                    HStack {
                        Text("전체 기록은 \(viewModel.allMotes.count)개 있습니다.")
                            .foregroundColor(.blue)
                            .font(.body)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                
                if !viewModel.filteredMotes.isEmpty {
                    Text("📍 \(locationManager.currentAddress)에서 심은 꽃")
                        .font(.headline)
                    
                    ScrollView {
                        ForEach(viewModel.filteredMotes.indices, id: \.self) { index in
                            let mote = viewModel.filteredMotes[index]
                            VStack(alignment: .leading, spacing: 4) {
                                Text("📒 \(mote.title)")
                                    .font(.headline)
                                Text("🗺️ \(mote.address)")
                                    .font(.caption)
                                Divider()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                if let currentLocation = locationManager.currentLocation {
                    let identifiableLocation = IdentifiableLocation(location: currentLocation)
                    
                    Map(initialPosition: .region(
                        MKCoordinateRegion(
                            center: identifiableLocation.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    )) {
                        Marker("내 위치", coordinate: identifiableLocation.coordinate)
                            .tint(.blue)
                    }
                    .mapStyle(.standard)
                    .frame(height: 200)
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding(.top,40)
            .padding()
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .onAppear {
                viewModel.loadAllMotes()
                if let location = locationManager.currentLocation {
                    viewModel.filterMotesByLocation(currentLocation: location)
                }
            }
        }
    }
}

struct IdentifiableLocation: Identifiable {
    let id = UUID()
    let location: CLLocation
    
    var coordinate: CLLocationCoordinate2D {
        location.coordinate
    }
}

