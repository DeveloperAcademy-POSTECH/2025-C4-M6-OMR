//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/21/25.
//

import SwiftUI
import DesignSystem

struct ARButton: View {
    let action: () -> Void
    
    private let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.27), lineWidth: 1)
                    .background(
                        Circle().fill(
                            RadialGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.white.opacity(0.0), location: 0.7837),
                                    .init(color: Color.white.opacity(0.14), location: 1.0),
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: (screenWidth * 0.9) / 2
                            )
                        )
                    )
                    .frame(width: screenWidth * 0.9, height: screenWidth * 0.9)
                
                Circle()
                    .stroke(Color.white.opacity(0.85), lineWidth: 1)
                    .background(
                        Circle().fill(
                            RadialGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.white.opacity(0.0), location: 0.7837),
                                    .init(color: Color.white.opacity(0.30), location: 1.0),
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: (screenWidth * 0.7) / 2
                            )
                        )
                    )
                    .opacity(0.52)
                    .frame(width: screenWidth * 0.7, height: screenWidth * 0.7)
                
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(hex: "#B4F2FD"), location: 0.3497),
                                .init(color: Color(red: 185/255, green: 253/255, blue: 218/255).opacity(0.02), location: 1.0)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: (screenWidth * 0.6) / 2
                        )
                    )
                    .opacity(0.5)
                    .frame(width: screenWidth * 0.6, height: screenWidth * 0.6)
                
                DesignSystemAssets.image(named: "flowerLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .opacity(0.5)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}


// Color Hex 확장
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

