//
//  MapView.swift
//  Features
//
//  Created by eunsong on 7/15/25.
//

import SwiftUI
import MapKit
import DesignSystem

public struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var moveToUserLocation = false
    @EnvironmentObject private var nav: NavigationViewModel
    
    public init() {}
    
    public var body: some View {
        ZStack {
            MapViewRepresentable(
                viewModel: viewModel,
                moveToUserLocation: $moveToUserLocation
            )
            .ignoresSafeArea()
            
            uiControls
        }
        .onAppear {
            viewModel.fetchMapObjects()
        }
        .sheet(item: $viewModel.selectObjectDetail) { summary in
            RecordDetailBottomSheet(viewModel: RecordDetailViewModel(id: summary.id))
        }
    }
    
    // MARK: - Composed Subviews
    
    @ViewBuilder
    private var uiControls: some View {
        VStack {
            HStack(alignment: .top) {
                topBar
                
                Spacer()
                
                locationButton
                    .padding(.top, 52)
                    .padding(.trailing, 20)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private var topBar: some View {
        Button {
            nav.pop()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .padding(12)
        }
        .padding(.top, 8)
        .padding(.leading, 8)
    }
    
    /// 우하단 내 위치로 이동 버튼
    @ViewBuilder
    private var locationButton: some View {
        MyLocationButton {
            moveToUserLocation = true
        }
    }
}


#Preview {
    MapView()
}
