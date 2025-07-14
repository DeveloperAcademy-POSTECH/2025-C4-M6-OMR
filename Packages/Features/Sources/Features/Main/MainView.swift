//
//  MainView.swift
//  Features
//
//  Created by eunsong on 7/15/25.
//
import SwiftUI

struct MainView: View {
    @EnvironmentObject private var nav: NavigationViewModel

    var body: some View {
        Button("AR 보기") {
            nav.push(.arCamera)
        }
    }
}
