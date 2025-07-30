//
//  MapView.swift
//  Features
//
//  Created by eunsong on 7/15/25.
//

import SwiftUI
import MapKit
import DesignSystem
import Dependencies

public struct MapView: View {
    @StateObject private var viewModel: MapViewModel
    @State private var moveToUserLocation = false
    @EnvironmentObject private var nav: NavigationViewModel
    
    public init() {
        // View가 생성되는 시점의 의존성을 가져옵니다.
        @Dependency(\.fetchMyRecordsUseCase) var fetchMyRecordsUseCase
        
        // 가져온 의존성을 ViewModel에 직접 주입합니다.
        self._viewModel = StateObject(
            wrappedValue:
                MapViewModel(
                fetchMyRecordsUseCase: fetchMyRecordsUseCase
            )
        )
    }

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
        VStack(spacing: 0) {
            // 상단 배경
            LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.3),
                            Color.black.opacity(0.15),
                            Color.black.opacity(0.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 200)
                    .ignoresSafeArea(edges: .top)
            
            Spacer()
        }
        .overlay( // 오버레이로 버튼을 배치
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
        )
    }

    
    @ViewBuilder
    private var topBar: some View {
        Button {
            nav.pop()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(DesignSystem.Color.Gray_white)
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
