//
//  AppRoute.swift
//  Features
//
//  Created by eunsong on 7/15/25.
//
import Foundation

/// 앱 내 모든 이동 지점을 열거형으로 관리
public enum AppRoute: Hashable {
    // 메인탭(홈)
    case home                 // MainView 기본
    // 지도
    case map(latitude: Double, longitude: Double)
    // AR 카메라
    case arCamera
    // 기록 상세
    case detail(moteId: UUID)
    // 기록 작성 플로우
    case recordStart
    case recordSelectSong
    case recordCompose(songId: String)
    case recordOverview(tempId: UUID)
    case recordComplete(moteId: UUID)
}
