import SwiftUI
import CoreLocation
import DesignSystem

// MARK: - MainView

struct MainView: View {
    @EnvironmentObject private var nav: NavigationViewModel
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = MainViewModel()
    
    @State private var sheetDetent: Detent = .low
    @State private var isSheetVisible = true
    @State private var previousLocation: CLLocation? = nil
    private let updateThresholdMeters: Double = 20.0
    
    var body: some View {
        GeometryReader { geometry in
            let detentOffsets = (
                large: Detent.large.offset(in: geometry),
                low: Detent.low.offset(in: geometry)
            )
            
            ZStack(alignment: .top) {
                content
                
                if isSheetVisible {
                    CustomModalView(
                        sheetDetent: $sheetDetent,
                        isSheetVisible: $isSheetVisible,
                        totalCount: $viewModel.totalCount,
                        detentOffsets: detentOffsets,
                        bottomSafeArea: geometry.safeAreaInsets.bottom
                    )
                    .frame(height: geometry.size.height)
                    .transition(.move(edge: .bottom))
                }
            }
            .animation(.snappy(duration: 0.35, extraBounce: 0.08), value: sheetDetent)
            .onReceive(locationManager.$currentLocation.compactMap { $0 }) { location in
                // 최초 위치 업데이트 시 한 번만 호출
                guard previousLocation == nil else {
                    handleLocationUpdate(location)
                    return
                }
                
                previousLocation = location
                let center = Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                viewModel.loadNearbyMotesMock(center: center, radius: 1000)
            }
        }
        
    }
    
    private var content: some View {
        VStack(spacing: 16) {
            currentAddressView
                .padding(.top, 100)
            
            if viewModel.isLoading {
                ProgressView()
            } else {
                Text("\(viewModel.totalCount)")
                Text("\(viewModel.nearbyCount)")
                Text(viewModel.nearbyCount == 0 ? "주변에 과거에 기록한 꽃이 없어요" : "주변에 과거에 기록한 꽃이 있어요")
                    .font(.custom("Pretendard", size: 18).weight(.semibold))
                    .foregroundColor(.black)
                    .padding()
            }
            
            ARButton(action: {
                nav.push(.arCamera)
            })
            
            Button("디자인 시스템 예제 보기") {
                nav.push(.designSystemExample)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [DesignSystem.Color.background1, DesignSystem.Color.background2]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var currentAddressView: some View {
        HStack {
            Image(systemName: "paperplane.fill")
                .foregroundColor(.blue)
            Text(locationManager.currentAddress)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
        }
    }
}

// MARK: - Helpers

extension MainView {
    
    private func handleLocationUpdate(_ location: CLLocation) {
        guard let prev = previousLocation else {
            previousLocation = location
            return
        }
        
        let distance = location.distance(from: prev)
        if distance < updateThresholdMeters { return }
        
        previousLocation = location
        
        let center = Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        viewModel.loadNearbyMotesMock(center: center, radius: 1000)
    }
}
