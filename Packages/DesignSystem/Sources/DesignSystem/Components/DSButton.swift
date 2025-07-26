//
//  DSButton.swift
//  Features
//
//  Edited by Jimin on 7/24/25.
//

import SwiftUI

struct ARButton: View {
    let systemName: String
    let width: CGFloat
    let height: CGFloat
    let iconSize: CGFloat
    let iconWeight: Font.Weight
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .foregroundColor(.white)
                .font(.system(size: iconSize, weight: iconWeight))
                .frame(width: width, height: height)
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
            width: 84,
            height: 84,
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
            width: 36,
            height: 36,
            iconSize: 16,
            iconWeight: .medium,
            action: action
        )
    }
}

struct ARConfirmationButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("완료")
                .font(Font.custom("Pretendard", size: 20).weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .frame(width: 68, height: 68)
                .background(
                  EllipticalGradient(
                    stops: [
                      Gradient.Stop(color: Color(red: 0.31, green: 0.85, blue: 0.43).opacity(0.1), location: 0.00),
                      Gradient.Stop(color: Color(red: 0.31, green: 0.85, blue: 0.43).opacity(0.4), location: 0.78),
                      Gradient.Stop(color: Color(red: 0.31, green: 0.85, blue: 0.43).opacity(0.6), location: 1.00),
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

struct ARFlowerButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            DesignSystemAssets.image(named: "piumFlower")
                .frame(width: 68, height: 68)
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

struct ARCancelButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack (alignment: .center, spacing: 6){
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                Text("꽃 심기 취소")
                    .font(Font.custom("Pretendard", size:14).weight(.medium))
                    .foregroundColor(.white)

            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(height: 36, alignment: .center)
            .background(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: .white.opacity(0.42), location: 0.00),
                        Gradient.Stop(color: .white.opacity(0.2), location: 0.48),
                        Gradient.Stop(color: .white.opacity(0.39), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 1.13, y: 0.46),
                    endPoint: UnitPoint(x: 0, y: 0.5)
                )
            )
            .cornerRadius(171)
            .shadow(color: .black.opacity(0.1), radius: 10, x:0, y:0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MyLocationButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action){
            Image(systemName: "location")
                .foregroundColor(DesignSystem.Color.Prime)
                .font(.system(size: 18))
                .multilineTextAlignment(.center)
                .frame(width: 38, height: 38)
                .background(DesignSystem.Color.Gray_01.opacity(0.7))
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.18), radius: 5, x: 0, y: 0)
            
        }
        .buttonStyle(PlainButtonStyle())
    }
}



struct HomeButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action){
            DesignSystemAssets.image(named: "buttonFlower")
                .scaledToFit()
                .frame(width: 36, height: 36, alignment: .center)
                .background(
                    EllipticalGradient(
                        stops: [
                            Gradient.Stop(color: Color(red: 0.96, green: 0.98, blue: 1), location: 0.00),
                            Gradient.Stop(color: Color(red: 0.86, green: 0.92, blue: 1), location: 1.00),
                        ],
                        center: UnitPoint(x: 0.5, y:0.5)
                    )
                )
                .clipShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}


struct CustomButtonView: View {
    var body: some View {
        
        VStack {
            HStack {
                ARPlusButton(){
                    print("tapped")
                }
                ARCloseButton(){
                    print("tapped2")
                }
            }
            HStack {
                ARConfirmationButton(){
                    print("tapped3")
                }
                ARFlowerButton(){
                    print("tapped4")
                }
            }
            HStack {
                ARCancelButton(){
                    print("tapped5")
                }
            }
            HStack {
                MyLocationButton() {
                    print("tapped6")
                }
                HomeButton() {
                    print("I changed something")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Color.Gray_04)
    }
}




#Preview {
    CustomButtonView()
}
