//
//  SwiftUIView.swift
//  DesignSystem
//
//  Created by Woody on 7/23/25.
//
import SwiftUI

struct AlertPopup: View {
    @Binding var isPresented: Bool
    let title: String
     let message: String
     let confirmText: String
     let cancelText: String
     let onConfirm: () -> Void
     let onCancel: () -> Void

     private let popupWidth: CGFloat = 270
     private let popupHeight: CGFloat = 168

    var body: some View {
        if isPresented {
            ZStack {
                // 1. 반투명 검은 배경 (어두워지는 효과)
                Color.gray.opacity(0.4)
                    .ignoresSafeArea()

                // 2. 팝업 내용
                VStack(spacing: 0) {
                    // 기존 팝업 내용 그대로
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 16)
                        .padding(.bottom, 4)

                    Text(message)
                        .font(.system(size: 13))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)

                    Divider()

                    Button {
                        isPresented = false
                        onConfirm()
                    } label: {
                        Text(confirmText)
                            .font(.system(size: 17))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }

                    Divider()

                    Button {
                        isPresented = false
                        onCancel()
                    } label: {
                        Text(cancelText)
                            .font(.system(size: 17))
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                }
                .frame(width: popupWidth, height: popupHeight)
                .background(Color(hex: "D7D6D0"))
                .cornerRadius(16)
                .shadow(radius: 20)
                .scaleEffect(isPresented ? 1 : 0.8)
                .opacity(isPresented ? 1 : 0)
                .transition(.scale)
                .animation(.easeInOut(duration: 0.25), value: isPresented)
            }
        }
    }
}



extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64

        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RRGGBB (24-bit)
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // AARRGGBB (32-bit)
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




struct AlertPopup_Previews: PreviewProvider {
    struct PreviewContainer: View {
        @State private var showPopup = true

        var body: some View {
            ZStack {
                VStack {
                    Text("배경 내용")
                    Button("팝업 열기") {
                        showPopup = true
                    }
                }

                AlertPopup(
                    isPresented: $showPopup,
                    title: "이 기록을 삭제할까요?",
                    message: "배치한 꽃과 기록이 전부 삭제됩니다.",
                    confirmText: "삭제",
                    cancelText: "취소",
                    onConfirm: { print("삭제 완료") },
                    onCancel: { print("취소됨") }
                )
            }
        }
    }

    static var previews: some View {
        PreviewContainer()
    }
}
