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
                    case .home:
                        MainView()
                    // TODO: 나머지 route 처리
                    case .designSystemExample:
                        DesignSystemExampleView()
                        
                    default:
                        Text("Not Found")

//                    case .map(let lat, let lon):
//                        MapView(latitude: lat, longitude: lon)
//
//                    case .arCamera:
//                        ARCameraView()
//
//                    case .detail(let moteId):
//                        DetailRecordView(moteId: moteId)
//
//                    case .recordStart:
//                        RecordView()
//
//                    case .recordSelectSong:
//                        SongSearchView()
//
//                    case .recordCompose(let songId):
//                        RecordComposeView(songId: songId)
//
//                    case .recordOverview(let tempId):
//                        RecordOverviewView(tempId: tempId)
//
//                    case .recordComplete(let moteId):
//                        RecordCompleteView(moteId: moteId)
                    }
                }
        }
        .environmentObject(nav)  // 하위 View에서 @EnvironmentObject 로 사용
    }
}
