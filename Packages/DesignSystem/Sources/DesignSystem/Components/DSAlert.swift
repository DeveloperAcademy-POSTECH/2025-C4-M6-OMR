//
//  SwiftUIView.swift
//  DesignSystem
//
//  Created by Woody on 7/23/25.
//
import SwiftUI


struct CustomAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let confirmText: String
    let cancelText: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $isPresented) {
                Button(cancelText, role: .cancel, action: onCancel)
                Button(confirmText, role: .destructive, action: onConfirm)
            } message: {
                Text(message)
            }
    }
}


extension View {
    func customAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        confirmText: String = "확인",
        cancelText: String = "취소",
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        self.modifier(CustomAlertModifier(
            isPresented: isPresented,
            title: title,
            message: message,
            confirmText: confirmText,
            cancelText: cancelText,
            onConfirm: onConfirm,
            onCancel: onCancel
        ))
    }
}
struct CustomAlertDemoView: View {
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("기록 화면")
            
            Button("삭제 팝업 열기") {
                showAlert = true
            }
        }
        .customAlert(
            isPresented: $showAlert,
            title: "이 기록을 삭제할까요?",
            message: "배치한 꽃과 기록이 전부 삭제됩니다.",
            confirmText: "삭제",
            cancelText: "취소",
            onConfirm: { print("삭제 완료") },
            onCancel: { print("취소됨") }
        )
    }
}

#Preview {
    CustomAlertDemoView()
}

