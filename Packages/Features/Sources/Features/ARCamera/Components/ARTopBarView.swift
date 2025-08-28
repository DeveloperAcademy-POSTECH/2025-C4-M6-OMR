//
//  ARTopBarView.swift
//  Features
//
//  Created by eunsong on 7/26/25.
//

import SwiftUI
import DesignSystem

struct ARTopBarView: View {
    let onClose: () -> Void
    let onCancelPlacement: () -> Void
    let onMapTapped: () -> Void
    let mode: ARCameraMode
    @State private var showCancelAlert = false

    var body: some View {
        HStack {
            // Map 버튼
            ARMapButton {
                onMapTapped()
            }
            
            Spacer()
            
            if mode == .normal {
                ARCloseButton {
                    onClose()
                }
            } else {
                ARCancelButton {
                    showCancelAlert = true
                }
            }
        }
        .alert(
            "꽃 심기를 그만두실래요?",
            isPresented: $showCancelAlert
        ) {
            Button("그만둘래요", role: .destructive) {
                onCancelPlacement()
            }
            Button("계속할래요", role: .cancel) {}
        } message: {
            Text("방금 배치한 꽃은 사라지게 됩니다")
        }
    }
}
