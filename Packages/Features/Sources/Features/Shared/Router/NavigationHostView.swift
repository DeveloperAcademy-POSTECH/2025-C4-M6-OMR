import CoreLocation
//
//  NavigationHostView.swift
//  Features
//
//  Created by eunsong on 7/15/25.
//
import Dependencies
import SwiftUI

public struct NavigationHostView: View {
    @StateObject private var nav = NavigationViewModel()

    public init() {}

    // 각 화면 ViewModel은 DI로 내부에서 생성
    public var body: some View {
        NavigationStack(path: $nav.path) {
            MainView()  // 첫 화면
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {

                    case .arCamera(let latitude, let longitude):
                        let location = CLLocation(
                            latitude: latitude,
                            longitude: longitude
                        )
                        ToolbarHiddenWrapper(
                            content:
                                ARCameraView(location: location)
                        )

                    case .map:
                        ToolbarHiddenWrapper(
                            content:
                                MapView()
                        )

                    case .myRecord:
                        ToolbarHiddenWrapper(
                            content:
                                MyRecordView()
                        )

                    case .home:
                        ToolbarHiddenWrapper(
                            content:
                                MainView()
                        )

                    default:
                        Text("Not Found")
                    }
                }
        }
        .environmentObject(nav)  // 하위 View에서 @EnvironmentObject 로 사용
    }
}
