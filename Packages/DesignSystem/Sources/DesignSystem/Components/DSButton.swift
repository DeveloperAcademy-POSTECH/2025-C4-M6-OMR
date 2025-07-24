//
//  DSButton.swift
//  Features
//
//  Created by eunsong on 7/15/25.
//


import SwiftUI

struct ARPlusButton: View {
    var body: some View {
        Button(action: {
            print("Tapped!")
        }) {
            VStack(alignment: .center) {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.system(size: 34, weight: .regular))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .frame(width: 84, height: 84, alignment: .center)
            .background(
                EllipticalGradient(
                    stops: [
                        Gradient.Stop(color: .white.opacity(0.1), location: 0.00),
                        Gradient.Stop(color: .white.opacity(0.4), location: 0.78),
                        Gradient.Stop(color: .white.opacity(0.6), location: 1.00),
                    ],
                    center: UnitPoint(x: 0.5, y: 0.5)
                )
            )
            .cornerRadius(171)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CustomButtonView: View {
    var body: some View {
        VStack {
            ARPlusButton()
            DesignSystemAssets.image(named: "maintest")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Color.Gray_04)
    }
}

#Preview {
    CustomButtonView()
}
