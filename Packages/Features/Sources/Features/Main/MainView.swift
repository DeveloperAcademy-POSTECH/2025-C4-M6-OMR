import CoreLocation
import Dependencies
import DesignSystem
import Lottie
import SwiftUI

// MARK: - MainView

struct MainView: View {
    @EnvironmentObject private var nav: NavigationViewModel

    @StateObject private var viewModel: MainViewModel

    @State private var sheetDetent: Detent = .low
    @State private var isSheetVisible = true
    @State private var previousLocation: CLLocation? = nil
    private let updateThresholdMeters: Double = 20.0

    public init() {
        // View가 생성되는 시점의 의존성을 가져옵니다.
        @Dependency(\.fetchMyRecordsUseCase) var fetchMyRecordsUseCase
        @Dependency(\.initializeAppDataUseCase) var initializeAppDataUseCase
        
        // 가져온 의존성을 ViewModel에 직접 주입합니다.
        self._viewModel = StateObject(
            wrappedValue: MainViewModel(
                fetchMyRecordsUseCase: fetchMyRecordsUseCase,
                initializeAppDataUseCase: initializeAppDataUseCase
            )
        )
    }

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
                        locationManager: viewModel.locationManager,
                        detentOffsets: detentOffsets,
                        bottomSafeArea: geometry.safeAreaInsets.bottom
                    )
                    .frame(height: geometry.size.height)
                    .transition(.move(edge: .bottom))
                }
            }
            .animation(
                .snappy(duration: 0.35, extraBounce: 0.08),
                value: sheetDetent
            )
            .onAppear {
                viewModel.requestCurrentLocation()
            }
            .onReceive(
                viewModel.locationManager.$currentLocation.compactMap { $0 }
            ) { location in
                guard previousLocation == nil else {
                    handleLocationUpdate(location)
                    return
                }

                previousLocation = location
                viewModel.loadNearbyRecords(center: location, radius: 1000)
            }
        }
    }
}

// MARK: - Subviews

extension MainView {
    private var content: some View {
        VStack(spacing: 12) {
            currentAddressView
                .padding(.top, 65)

            if viewModel.isLoading {
                ProgressView()
            } else {
                Text(
                    viewModel.nearbyCount == 0
                        ? "꽃을 눌러 새로운 기록을 남겨보세요" : "주변에 과거에 기록한 꽃이 있어요"
                )
                .font(DesignSystem.Font.Title2.semibold)
                .foregroundColor(DesignSystem.Color.Gray_black)
                .padding(.bottom, 47)
            }

            ARButton(action: {
                if let location = viewModel.currentLocation {
                    nav.push(
                        .arCamera(
                            latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude
                        )
                    )
                } else {
                    print("안됨")
                }
            })

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    DesignSystem.Color.Prime4, DesignSystem.Color.Prime3,
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var currentAddressView: some View {
        HStack(spacing: 8) {
            Image(systemName: "location")
                .foregroundColor(DesignSystem.Color.Prime)
                .font(.system(size: 12, weight: .semibold))

            Text(viewModel.currentAddress)
                .font(DesignSystem.Font.Headline.semibold)
                .foregroundColor(DesignSystem.Color.Prime)

            Button(action: {
                viewModel.requestCurrentLocation()
            }) {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .foregroundColor(DesignSystem.Color.Prime)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
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
        viewModel.loadNearbyRecords(center: location, radius: 1000)
        print("\(viewModel.nearbyCount) 입니다.")
    }
}

#Preview {
    MainView()
}
