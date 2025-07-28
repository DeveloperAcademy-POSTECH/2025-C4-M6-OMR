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

    public init() {}

    public var body: some View {
        NavigationStack(path: $nav.path) {
            MainView()
                .navigationDestination(for: AppRoute.self) { route in
                    // Wrap the destination view with dependencies
                    withDependencies {
                        // Use the configured dependencies from Features module
                        $0.recordRepository =
                            FeaturesDependencies.current.recordRepository
                        $0.userRepository =
                            FeaturesDependencies.current.userRepository
                        $0.markerRepository =
                            FeaturesDependencies.current.markerRepository
                    } operation: {
                        destinationView(for: route)
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

            // Debug logging to verify dependencies
            let _ = print("[DI] Creating ARCameraView with dependencies")

            // Verify we have the right dependencies in this context
            @Dependency(\.recordRepository) var recordRepo
            let _ = print("[DI] RecordRepository type: \(type(of: recordRepo))")

            ToolbarHiddenWrapper(
                content:
                    ARCameraView(
                        location: location,
                        factory: LiveARCameraViewModelFactory()
                    )
            )

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
}
