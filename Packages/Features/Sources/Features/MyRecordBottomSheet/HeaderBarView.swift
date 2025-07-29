//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/22/25.
//

import SwiftUI
import DesignSystem

struct HeaderBarView: View {
    var onSettingsTapped: () -> Void
    var onCloseTapped: () -> Void
    
    var body: some View {
        HStack {
            // 환경설정 버튼
            Button(action: onSettingsTapped) {
                Image(systemName: "gearshape.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .foregroundColor(DesignSystem.Color.Prime)
            }
            
            Spacer()
            
            // 닫기 버튼
            
            HomeButton(action: onCloseTapped)

        }
        .padding(.bottom, 8)
    }
}

