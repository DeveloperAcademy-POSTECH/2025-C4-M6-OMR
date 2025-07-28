import CoreLocation
import DesignSystem
import SwiftUI
import Lottie

// MARK: - MainView

struct MainView: View {
    @EnvironmentObject private var nav: NavigationViewModel

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
                viewModel.loadNearbyMotesMock(center: location, radius: 1000)
            }
        }
    }
}

// MARK: - Subviews

extension MainView {
    private var content: some View {
        VStack(spacing: 16) {
            currentAddressView
                .padding(.top, 100)

            if viewModel.isLoading {
                ProgressView()
            } else {
                Text(
                    viewModel.nearbyCount == 0
                        ? "주변에 과거에 기록한 꽃이 없어요" : "주변에 과거에 기록한 꽃이 있어요"
                )
                .font(.custom("Pretendard", size: 18).weight(.semibold))
                .foregroundColor(DesignSystem.Color.Gray_black)
                .padding()
            }

            ARButton(action: {
                if let location = viewModel.currentLocation {
                    nav.push(
                        .arCamera(
                            latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude
                        )
                    )
                }
                else {
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
            Image(systemName: "paperplane.fill")
                .foregroundColor(DesignSystem.Color.Prime)

            Text(viewModel.currentAddress)
                .font(.system(size: 14, weight: .medium))
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
        viewModel.loadNearbyMotesMock(center: location, radius: 1000)
    }
}
