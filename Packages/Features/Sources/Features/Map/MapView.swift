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
        .sheet(item: $viewModel.selectObjectDetail) { summary in
            RecordDetailBottomSheet(viewModel: RecordDetailViewModel(summary: summary))
        }
    }
}

#Preview {
    MapView()
}
