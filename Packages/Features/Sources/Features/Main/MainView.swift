//
//  MainView.swift
//  Features
//
//  Created by eunsong on 7/15/25.
//
import SwiftUI
import DesignSystem

struct MainView: View {
    @EnvironmentObject private var nav: NavigationViewModel

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Button("AR 보기") {
                    nav.push(.arCamera)
                }
                
                Button("디자인 시스템 예제 보기") {
                    nav.push(.designSystemExample)
                }
            }
        }
    }
}
