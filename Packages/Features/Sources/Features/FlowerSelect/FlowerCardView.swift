//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/23/25.
//

import SwiftUI
import DesignSystem

struct FlowerCardView: View {
    let flower: FlowerModel
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            DesignSystemAssets.image(named: flower.objectImageName)
                .resizable()
                .scaledToFit()
                .frame(height: 70)
            
            Text(flower.name)
                .font(
                    Font.custom("Pretendard", size: 14)
                        .weight(.medium)
                )
                .foregroundColor(DesignSystem.Color.Gray_black)
            Text(flower.floriography)
                .font(Font.custom("Pretendard", size: 12))
                .multilineTextAlignment(.center)
                .foregroundColor(DesignSystem.Color.Gray_black)
                .opacity(0.8)
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
        .padding(.bottom, 10)
        .frame(width: 86, height: 130, alignment: .center)
        .background(isSelected ? DesignSystem.Color.Gray_01 : Color.white)
        .cornerRadius(20)
    }
}
