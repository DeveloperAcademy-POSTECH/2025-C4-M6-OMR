//
//  MainView.swift
//  Features
//
//  Created by eunsong on 7/15/25.
//
import SwiftUI
import CoreLocation
import DesignSystem

struct MainView: View {
    @EnvironmentObject private var nav: NavigationViewModel
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = MainViewModel()
    
    @State private var previousLocation: CLLocation? = nil
    let updateThresholdMeters = 20.0  // 20m 이상 이동했을 때만 업데이트
    
    // 👇 bottom sheet 제어용
    @State private var sheetPosition: SheetPosition = .half
    @GestureState private var dragOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                Text("현재 위치: \(locationManager.currentAddress)")
                    .font(.headline)
                    .padding()
                
                if viewModel.isLoading {
                    ProgressView()
                } else if !viewModel.motes.isEmpty {
                    Text("주변에 과거에 기록한 \(viewModel.motes.count) 모트가 있어요")
                        .font(.subheadline)
                        .padding()
                }

                Button("AR 보기") {
                    nav.push(.arCamera)
                }
                
                Button("디자인 시스템 예제 보기") {
                    nav.push(.designSystemExample)
                }
                
                Spacer()
            }
            
            // 👇 Bottom Sheet
            MyRecordBottomSheet(sheetPosition: $sheetPosition)
                .offset(y: sheetPosition.yOffset + dragOffset.height)
                .animation(.easeInOut, value: sheetPosition)
                .gesture(
                    sheetPosition == .full
                    ? nil
                    :  // full 상태에서는 드래그 gesture 제거
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded { value in
                            if value.translation.height < -100 {
                                sheetPosition = .full
                            } else if value.translation.height > 100 {
                                sheetPosition = .half
                            }
                        }
                )
            
        }
        .onReceive(locationManager.$currentLocation.compactMap { $0 }) {
            location in
            if let prev = previousLocation {
                let distance = location.distance(from: prev)
                if distance < updateThresholdMeters {
                    print("이동 거리가 작아서 업데이트 안 함: \(distance) m")
                    return
                }
            }
            
            previousLocation = location
            
            let center = Location(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            print(
                "현재 위치:",
                location.coordinate.latitude,
                location.coordinate.longitude
            )
            viewModel.loadNearbyMotesMock(center: center, radius: 10000)
        }
    }
}
