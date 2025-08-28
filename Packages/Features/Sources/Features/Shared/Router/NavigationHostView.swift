//
//  NavigationHostView.swift
//  Features
//
//  Created by eunsong on 7/15/25.
//
import CoreLocation
import Dependencies
import Domain
import SwiftUI

public struct NavigationHostView: View {
    @EnvironmentObject private var nav: NavigationViewModel
    @StateObject private var locationManager = LocationManager()
    
    private let configureDependencies: (inout DependencyValues) -> Void

    public init(
        configureDependencies: @escaping (inout DependencyValues) -> Void
    ) {
        self.configureDependencies = configureDependencies
    }

    public var body: some View {
            NavigationStack(path: $nav.path) {
                // 위치가 준비되면 AR 화면으로 이동, 아니면 로딩 화면
                if let location = locationManager.currentLocation {
                    if #available(iOS 18.0, *) {
                        withDependencies(configureDependencies) {
                            ToolbarHiddenWrapper(
                                content: ARCameraView(location: location)
                            )
                            .navigationDestination(for: AppRoute.self) { route in
                                destinationView(for: route)
                            }
                            .task {
                                // 의존성이 설정된 컨텍스트 내부에서 앱을 초기화
                                await initializeAppData()
                            } 
                        }
                    } else {
                        // iOS 18 미만 버전 대응
                        Text("iOS 18.0 이상이 필요합니다")
                    }
                } else {
                    // 위치 로딩 화면
                    LocationLoadingView()
                        .onAppear {
                            locationManager.requestLocationAgain()
                        }
                }
            }
           
        
    }

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {

        case .map:
            ToolbarHiddenWrapper(
                content: MapView()
            )

        case .myRecord:
            ToolbarHiddenWrapper(
                content: MyRecordView()
            )

        case .home:
            ToolbarHiddenWrapper(
                content: MainView()
            )

        default:
            Text("Not Found")
        }
    }
    
    @MainActor
    private func initializeAppData() async {
        @Dependency(\.initializeAppDataUseCase) var initializeAppDataUseCase

        do {
            print("[Features] Initializing app data...")
            try await initializeAppDataUseCase()
            print("[Features] App data initialized successfully")
        } catch {
            print("[Features] Failed to initialize app data: \(error)")
        }
    }
}

// MARK: - LocationLoadingView
struct LocationLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            // 로딩 애니메이션
            Circle()
                .stroke(Color.blue.opacity(0.3), lineWidth: 4)
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.blue, lineWidth: 4)
                        .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                )
            
            VStack(spacing: 8) {
                Text("위치 정보를 확인하는 중...")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("AR 경험을 위해 현재 위치가 필요합니다")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            isAnimating = true
        }
    }
}
