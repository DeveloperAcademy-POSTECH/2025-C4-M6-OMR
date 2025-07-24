//
//  DSButton.swift
//  Features
//
//  Edited by Jimin on 7/24/25.
//

import SwiftUI

struct ARButton: View {
    let systemName: String
    let size: CGFloat
    let iconSize: CGFloat
    let iconWeight: Font.Weight
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .foregroundColor(.white)
                .font(.system(size: iconSize, weight: iconWeight))
                .frame(width: size, height: size)
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
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.1), radius: 10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ARPlusButton: View {
    let action: () -> Void
    
    var body: some View {
        ARButton(
            systemName: "plus",
            size: 84,
            iconSize: 34,
            iconWeight: .regular,
            action: action
        )
    }
}

struct ARCloseButton: View {
    let action: () -> Void
    
    var body: some View {
        ARButton(
            systemName: "xmark",
            size: 36,
            iconSize: 16,
            iconWeight: .medium,
            action: action
        )
    }
}

struct CustomButtonView: View {
    var body: some View {
        VStack {
            ARPlusButton(){
                print("tapped")
            }
            ARCloseButton(){
                print("tapped2")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Color.Gray_04)
    }
}


#Preview {
    CustomButtonView()
}
