import SwiftUI
import CoreLocation
import DesignSystem

struct MainView: View {
    // MARK: - Environment
    @EnvironmentObject private var nav: NavigationViewModel
    
    // MARK: - ViewModels
    @StateObject private var viewModel = MainViewModel()
    @StateObject private var myRecordViewModel = MyRecordBottomSheetViewModel()
    
    // MARK: - States
    @State private var previousLocation: CLLocation? = nil
    @State private var sheetPosition: SheetPosition = .half
    @GestureState private var dragOffset: CGSize = .zero
    @State private var isFullScreen = false
    
    private let updateThresholdMeters: Double = 20.0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundGradient
            
            content
            
            // Bottom Sheet
            MyRecordBottomSheet(selectedPosition: $sheetPosition, viewModel: myRecordViewModel)
                .offset(y: sheetPosition.yOffset + dragOffset.height)
                .animation(.easeInOut, value: sheetPosition)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded(handleSheetDrag)
                )
        }
        .fullScreenCover(isPresented: $isFullScreen) {
            MyRecordFullScreenModalView(isPresented: $isFullScreen, viewModel: myRecordViewModel)
                .environmentObject(viewModel.locationManager)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.blue)
        }
    }
}

// MARK: - Subviews

extension MainView {
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [DesignSystem.Color.background1, DesignSystem.Color.background2]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var content: some View {
        VStack(spacing: 16) {
            currentAddressView
                .padding(.top, 100)
            
            if viewModel.isLoading {
                ProgressView()
            } else {
                Text(viewModel.motes.isEmpty ? "주변에 과거에 기록한 꽃이 없어요" : "주변에 과거에 기록한 꽃이 있어요")
                    .font(.custom("Pretendard", size: 18).weight(.semibold))
                    .foregroundColor(.black)
                    .padding()
            }
            
            ARButton(action: {
                if let location = viewModel.currentLocation {
                    nav.push(.arCamera(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
                }
            })
            
            Button("디자인 시스템 예제 보기") {
                nav.push(.designSystemExample)
            }
            
            Spacer()
        }
    }
    
    private var currentAddressView: some View {
        HStack {
            Image(systemName: "paperplane.fill")
                .foregroundColor(.blue)
            Text(viewModel.currentAddress)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
        }
    }
}

// MARK: - Helpers

extension MainView {
    private func handleSheetDrag(_ value: DragGesture.Value) {
        if value.translation.height < -100 {
            isFullScreen = true
            // Removed sheetPosition = .half to prevent conflict with fullScreenCover
        } else if value.translation.height > 100 {
            sheetPosition = .half
        }
    }
}

#Preview{
    MainView()
}
