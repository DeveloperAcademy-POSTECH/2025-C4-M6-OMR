//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/21/25.
//

import SwiftUI
import MapKit
import CoreLocation
import DesignSystem

struct MyRecordFullScreenModalView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var locationManager: LocationManager
    @ObservedObject var viewModel: MyRecordBottomSheetViewModel
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()  // 배경색 흰색으로 설정
            
            VStack {
                
                // 상단 고정 영역
                HeaderBarView(
                    onSettingsTapped: {
                        // 환경설정 액션 처리
                    },
                    onCloseTapped: {
                        isPresented = false
                    }
                )
                // Scroll 영역
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text("내 꽃")
                            .font(
                                Font.custom("Pretendard", size: 26)
                                    .weight(.bold)
                            )
                            .foregroundColor(Color(red: 0.1, green: 0.12, blue: 0.14))
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        
                        // 전체 기록 버튼
                        AllRecordButtonView(
                            totalCount: viewModel.allMotes.count,
                            onTap: {
                                print("전체 기록 보기로 이동")
                            }
                        )
                        
                        FilteredMoteListView(
                            filteredMotes: viewModel.filteredMotes,
                            currentAddress: locationManager.currentAddress
                        )
                        
                        // 지도
                        if let currentLocation = locationManager.currentLocation {
                            MapPreviewView(coordinate: currentLocation.coordinate) {
                                print("MapView로 이동")
                                // 네비게이션 등 원하는 동작 수행
                            }
                        }
                        
                    }
                }
                .scrollIndicators(.hidden)
            }
            .padding(.horizontal,20)
        }
        .onReceive(locationManager.$currentLocation.compactMap { $0 }) { location in
            viewModel.filterMotesByLocation(currentLocation: location)
            
        }
        .onAppear {
            viewModel.loadAllMotes()
            if let current = locationManager.currentLocation {
                viewModel.filterMotesByLocation(currentLocation: current)
            }
        }
        
    }
}
