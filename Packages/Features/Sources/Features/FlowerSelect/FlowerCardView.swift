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
            DesignSystemAssets.image(named: flower.thumbnailImageName)
                .resizable()
                .scaledToFit()
                .frame(height: 70)
            
            Text(flower.name)
                .font(
                    Font.custom("Pretendard", size: 14)
                        .weight(.medium)
                )
                .foregroundColor(Color(red: 0.1, green: 0.12, blue: 0.15))
            Text(flower.floriography)
                .font(Font.custom("Pretendard", size: 12))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.1, green: 0.12, blue: 0.15))
                .opacity(0.8)
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
        .padding(.bottom, 10)
        .frame(width: 86, height: 130, alignment: .center)
        .background(isSelected ? Color(red: 0.94, green: 0.96, blue: 1) : Color.white)
        .cornerRadius(20)
    }
}
