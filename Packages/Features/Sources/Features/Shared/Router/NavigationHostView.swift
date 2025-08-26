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
    
    private let configureDependencies: (inout DependencyValues) -> Void

    public init(
        configureDependencies: @escaping (inout DependencyValues) -> Void
    ) {
        self.configureDependencies = configureDependencies
    }

    public var body: some View {
        NavigationStack(path: $nav.path) {
            // 루트 뷰와 목적지 뷰 모두에 명시적으로 의존성을 주입합니다.
            withDependencies(configureDependencies) {
                MainView()
                    .navigationDestination(for: AppRoute.self) { route in
                        withDependencies(configureDependencies) {
                            destinationView(for: route)
                        }
                    }
                    .task {
                        // 의존성이 설정된 컨텍스트 내부에서 앱을 초기화합니다.
                        await initializeAppData()
                    }
            }
        }
    }

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .arCamera(let latitude, let longitude):
            let location = CLLocation(
                latitude: latitude,
                longitude: longitude
            )

            if #available(iOS 18.0, *) {
                ToolbarHiddenWrapper(
                    content:
                        ARCameraView(location: location)
                )
            } else {
                // Fallback on earlier versions
            }

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
