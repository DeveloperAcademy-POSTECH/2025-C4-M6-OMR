import SwiftUI
import CoreLocation
import DesignSystem

struct MainView: View {
    @EnvironmentObject private var nav: NavigationViewModel
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = MainViewModel()
    
    @State private var previousLocation: CLLocation? = nil
    let updateThresholdMeters = 20.0
    
    @State private var sheetPosition: SheetPosition = .half
    @GestureState private var dragOffset: CGSize = .zero
    
    @State private var isFullScreen = false
    
    var body: some View {
            ZStack(alignment: .bottom) {
                Color.white.ignoresSafeArea()
                
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
                
                // Bottom Sheet
                MyRecordBottomSheet(selectedPosition: $sheetPosition, locationManager: locationManager)
                    .offset(y: sheetPosition.yOffset + dragOffset.height)
                    .animation(.easeInOut, value: sheetPosition)
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation
                            }
                            .onEnded { value in
                                if value.translation.height < -100 {
                                    // 충분히 올렸을 때 fullScreenCover 띄우고 bottom sheet 숨김
                                    isFullScreen = true
                                    sheetPosition = .half // 초기화
                                } else if value.translation.height > 100 {
                                    sheetPosition = .half
                                }
                            }
                    )
            }
            .onReceive(locationManager.$currentLocation.compactMap { $0 }) { location in
                if let prev = previousLocation {
                    let distance = location.distance(from: prev)
                    if distance < updateThresholdMeters {
                        return
                    }
                }
                previousLocation = location
                
                let center = Location(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                viewModel.loadNearbyMotesMock(center: center, radius: 1000)
            }
            .fullScreenCover(isPresented: $isFullScreen) {
                FullScreenModalView(isPresented: $isFullScreen, locationManager: locationManager)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity,
                                       maxHeight: .infinity)
                                .background(Color.blue)
                                .ignoresSafeArea(edges: .all)

                    
            }
            
        }
    }

