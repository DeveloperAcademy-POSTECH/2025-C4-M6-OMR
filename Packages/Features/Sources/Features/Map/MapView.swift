//
//  MapView.swift
//  Features
//
//  Created by eunsong on 7/15/25.
//

import SwiftUI
import MapKit

public struct MapView: View {
    
    @StateObject private var viewModel = MapViewModel()

    @State private var moveToUserLocation = false
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MapViewRepresentable(viewModel: viewModel, moveToUserLocation: $moveToUserLocation)
                .ignoresSafeArea()

            // '내 위치로' 버튼
            Button {
                moveToUserLocation = true
            } label: {
                Image(systemName: "location.fill")
                    .padding()
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            .padding()
        }
        .onAppear {
            viewModel.fetchMapObjects()
        }
        .sheet(item: $viewModel.selectObjectDetail) { detail in
            VStack(alignment: .leading, spacing: 16) {
                Text(detail.title)
                    .font(.largeTitle.bold())
                
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text("위도: \(detail.latitude)")
                }
                
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text("경도: \(detail.longitude)")
                }
            }
            .padding(30)
            // iOS 16+ 에서 사용 가능한 시트 높이 조절
            .presentationDetents([.height(250), .medium])
        }
    }
}

#Preview {
    MapView()
}
