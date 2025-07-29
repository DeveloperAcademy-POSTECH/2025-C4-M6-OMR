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
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            // 닫기 버튼
            Button(action: onCloseTapped) {
                ZStack {
                    EllipticalGradient(
                        stops: [
                            .init(color: Color(red: 0.96, green: 0.98, blue: 1), location: 0.00),
                            .init(color: Color(red: 0.86, green: 0.92, blue: 1), location: 1.00),
                        ],
                        center: .center
                    )
                    .frame(width: 36, height: 36)
                    .cornerRadius(99)
                    
                    DesignSystemAssets.image(named: "flowerLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .clipShape(Circle())
                        .opacity(0.5)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 8)
    }
}

