import SwiftUI
import CoreLocation
import DesignSystem

struct MainView: View {
    @EnvironmentObject private var nav: NavigationViewModel
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = MainViewModel()
    
    @State private var previousLocation: CLLocation? = nil
    let updateThresholdMeters = 20.0
    
    @State private var isBottomSheetPresented = true
    @State private var selectedDetent: PresentationDetent = .fraction(0.2)
    
    var body: some View {
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
        .sheet(isPresented: $isBottomSheetPresented) {
            MyRecordBottomSheet(selectedDetent: $selectedDetent)
                .environmentObject(locationManager)
                .presentationDetents(
                    [.fraction(0.2), .fraction(1.0)],
                    selection: $selectedDetent
                )
                .presentationDragIndicator(
                    selectedDetent == .fraction(1.0) ? .hidden : .visible
                )
                .interactiveDismissDisabled(true)
        }
        .onReceive(locationManager.$currentLocation.compactMap { $0 }) { location in
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
            print("현재 위치:", location.coordinate.latitude, location.coordinate.longitude)
            viewModel.loadNearbyMotesMock(center: center, radius: 10000)
        }
    }
}
